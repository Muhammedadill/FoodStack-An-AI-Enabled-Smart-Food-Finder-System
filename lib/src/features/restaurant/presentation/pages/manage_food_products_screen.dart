import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:food_reel_app/src/shared/services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ManageFoodProductsScreen extends ConsumerStatefulWidget {
  const ManageFoodProductsScreen({super.key});

  @override
  ConsumerState<ManageFoodProductsScreen> createState() =>
      _ManageFoodProductsScreenState();
}

class _ManageFoodProductsScreenState
    extends ConsumerState<ManageFoodProductsScreen> {
  void _showAddEditDialog({FoodProduct? product}) {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final priceCtrl =
        TextEditingController(text: product?.price.toString() ?? '');
    String category = product?.category ?? AppCategories.mainCourse;
    bool isVeg = product?.isVeg ?? true;
    String? imageUrl = product?.imageUrl;
    String? localImagePath;
    bool isUploadingImage = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(product == null ? 'Add Food Item' : 'Edit Food Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image picker
                    GestureDetector(
                      onTap: isUploadingImage
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 800,
                                imageQuality: 80,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  localImagePath = picked.path;
                                });
                              }
                            },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: () {
                          final path = localImagePath;
                          final url = imageUrl;
                          if (path != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(path),
                                fit: BoxFit.cover,
                              ),
                            );
                          } else if (url != null && url.isNotEmpty) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              ),
                            );
                          }
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 36, color: Colors.grey),
                              SizedBox(height: 4),
                              Text('Tap to add image',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          );
                        }(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppCategories.all
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => category = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(isVeg ? 'Vegetarian' : 'Non-Vegetarian'),
                      secondary: Icon(
                        Icons.circle,
                        color: isVeg ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      value: isVeg,
                      onChanged: (val) {
                        setDialogState(() => isVeg = val);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    if (isUploadingImage)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Uploading image...',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isUploadingImage
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isEmpty ||
                              priceCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Name and price are required')),
                            );
                            return;
                          }

                          // Upload image to Cloudinary if a new one was picked
                          String finalImageUrl = imageUrl ?? '';
                          if (localImagePath != null) {
                            setDialogState(() => isUploadingImage = true);
                            try {
                              final uploadedUrl =
                                  await CloudinaryService.uploadImage(
                                      localImagePath!);
                              if (uploadedUrl != null) {
                                finalImageUrl = uploadedUrl;
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Image upload failed: $e')),
                                );
                              }
                              setDialogState(() => isUploadingImage = false);
                              return;
                            }
                            setDialogState(() => isUploadingImage = false);
                          }

                          final newProduct = FoodProduct(
                            id: product?.id ?? const Uuid().v4(),
                            restaurantId: user.id,
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            price:
                                double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                            category: category,
                            imageUrl: finalImageUrl,
                            isVeg: isVeg,
                            isAvailable: product?.isAvailable ?? true,
                          );

                          final repo = ref.read(foodProductRepositoryProvider);
                          if (product == null) {
                            await repo.addProduct(newProduct);
                          } else {
                            await repo.updateProduct(newProduct);
                          }
                          ref.invalidate(foodProductsProvider(user.id));
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                  child: Text(product == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteProduct(String productId) {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this food item?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref
                  .read(foodProductRepositoryProvider)
                  .deleteProduct(productId);
              ref.invalidate(foodProductsProvider(user.id));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    final productsAsync = ref.watch(foodProductsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food Items'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No food items yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first food item',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Group by category
          final grouped = <String, List<FoodProduct>>{};
          for (final p in products) {
            grouped.putIfAbsent(p.category, () => []).add(p);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  ...entry.value.map((product) => _ProductCard(
                        product: product,
                        onEdit: () => _showAddEditDialog(product: product),
                        onDelete: () => _deleteProduct(product.id),
                        onToggleAvailability: () async {
                          final updated = product.copyWith(
                              isAvailable: !product.isAvailable);
                          await ref
                              .read(foodProductRepositoryProvider)
                              .updateProduct(updated);
                          ref.invalidate(foodProductsProvider(user.id));
                        },
                      )),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final FoodProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image or veg indicator
            if (product.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _vegIndicator(),
                ),
              )
            else
              _vegIndicator(),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: product.isVeg ? Colors.green : Colors.red,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.circle,
                            size: 7,
                            color: product.isVeg ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: product.isAvailable
                                ? null
                                : TextDecoration.lineThrough,
                            color: product.isAvailable ? null : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (product.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        product.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            // Availability toggle
            Switch(
              value: product.isAvailable,
              onChanged: (_) => onToggleAvailability(),
              activeTrackColor: Colors.green,
            ),
            // Actions
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _vegIndicator() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color:
            (product.isVeg ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant,
        color: product.isVeg ? Colors.green : Colors.red,
        size: 28,
      ),
    );
  }
}
