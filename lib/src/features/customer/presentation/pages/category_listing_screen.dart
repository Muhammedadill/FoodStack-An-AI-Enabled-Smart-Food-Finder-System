import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:food_reel_app/src/features/customer/presentation/providers/cart_provider.dart';

class CategoryListingScreen extends ConsumerWidget {
  final String category;

  const CategoryListingScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reelsAsync = ref.watch(reelsStreamProvider);
    final productsAsync = ref.watch(allProductsStreamProvider);
    final restaurantsAsync = ref.watch(restaurantsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: reelsAsync.when(
        data: (reels) => productsAsync.when(
          data: (products) => restaurantsAsync.when(
            data: (restaurants) {
              // Combine both into a list of reels (convert products to reels for UI)
              final List<FoodReel> combinedItems = [];

              // Add reels in this category
              combinedItems.addAll(reels.where(
                  (r) => r.category.toLowerCase() == category.toLowerCase()));

              // Add products as reels in this category
              for (final p in products) {
                if (p.category.toLowerCase() == category.toLowerCase()) {
                  // Avoid duplicates if a reel and product share the same name/id
                  if (!combinedItems.any((r) =>
                      r.id == p.id ||
                      r.dishName.toLowerCase() == p.name.toLowerCase())) {
                    combinedItems.add(FoodReel(
                      id: p.id,
                      restaurantId: p.restaurantId,
                      videoUrl: p.imageUrl,
                      description: p.description,
                      dishName: p.name,
                      price: p.price,
                      category: p.category,
                    ));
                  }
                }
              }

              if (combinedItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No items found in $category',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: combinedItems.length,
                itemBuilder: (context, index) {
                  final reel = combinedItems[index];
                  final restaurant = restaurants.firstWhere(
                    (r) => r.id == reel.restaurantId,
                    orElse: () => restaurants.first,
                  );

                  return _CategoryItemCard(
                      reel: reel, restaurantName: restaurant.name);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CategoryItemCard extends ConsumerWidget {
  final FoodReel reel;
  final String restaurantName;

  const _CategoryItemCard({required this.reel, required this.restaurantName});

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('/video/upload/') ||
        lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.contains('.mkv');
  }

  String _getDisplayImage(String url) {
    if (url.isEmpty) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500';
    }
    if (!_isVideoUrl(url)) return url;

    if (url.contains('/video/upload/')) {
      // Cloudinary specific transformation for video to image
      return url.replaceAll(RegExp(r'\.(mp4|mov|avi|mkv|webm)$'), '.jpg');
    }

    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _getDisplayImage(reel.videoUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.orange[50],
                      child:
                          const Icon(Icons.fastfood, color: Colors.deepOrange),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border,
                          size: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reel.dishName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  restaurantName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${reel.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        cartNotifier.addItem(reel);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${reel.dishName} added to cart'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.deepOrange,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
