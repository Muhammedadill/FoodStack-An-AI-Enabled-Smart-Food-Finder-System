import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:food_reel_app/src/features/customer/presentation/providers/cart_provider.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:go_router/go_router.dart';

class RestaurantDetailsScreen extends ConsumerWidget {
  final String id;
  const RestaurantDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantProvider(id));
    final reelsAsync = ref.watch(reelsStreamProvider);
    final productsAsync = ref.watch(foodProductsProvider(id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: restaurantAsync.when(
        data: (restaurant) => CustomScrollView(
          slivers: [
            // Collapsible Header
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  restaurant.imageUrl.isNotEmpty
                      ? restaurant.imageUrl
                      : 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800',
                  fit: BoxFit.cover,
                ),
              ),
              leading: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_back, color: Colors.black),
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.share, color: Colors.black),
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            // Restaurant Info Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.green, size: 20),
                        const SizedBox(width: 4),
                        const Flexible(
                          child: Text(
                            '4.8 (100+ ratings)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('•'),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            restaurant.cuisine,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text('${restaurant.deliveryTime} mins'),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              restaurant.address,
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (restaurant.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        restaurant.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Menu Items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Combined Menu Items List
            reelsAsync.when(
              data: (allReels) => productsAsync.when(
                data: (products) {
                  final reels = allReels
                      .where((r) => r.restaurantId == restaurant.id)
                      .toList();

                  // Group items by category
                  final Map<String, List<_MenuItem>> groupedItems = {};

                  // Products first
                  for (final p in products) {
                    final item = _MenuItem(
                      name: p.name,
                      description: p.description,
                      price: p.price,
                      imageUrl: p.imageUrl,
                      product: p,
                    );
                    groupedItems.putIfAbsent(p.category, () => []).add(item);
                  }

                  // Reels
                  for (final r in reels) {
                    final item = _MenuItem(
                      name: r.dishName,
                      description: r.description,
                      price: r.price,
                      imageUrl: r.videoUrl,
                      reel: r,
                    );
                    // Reels might have category if newly uploaded, otherwise default
                    groupedItems.putIfAbsent(r.category, () => []).add(item);
                  }

                  if (groupedItems.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No menu items available yet.'),
                        ),
                      ),
                    );
                  }

                  // Flatten for SliverList
                  final List<_MenuListItem> flattenedList = [];
                  // Sort categories: Recommended/Main Course first if they exist
                  final sortedCategories = groupedItems.keys.toList()..sort();

                  for (final category in sortedCategories) {
                    flattenedList.add(_MenuListItem.header(category));
                    for (final item in groupedItems[category]!) {
                      flattenedList.add(_MenuListItem.item(item));
                    }
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = flattenedList[index];
                        if (entry.type == _MenuListItemType.header) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.headerTitle!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  height: 3,
                                  width: 40,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return _MenuCard(item: entry.item!);
                      },
                      childCount: flattenedList.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) =>
                    SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
              ),
              loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) =>
                  SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: restaurantAsync.when(
        data: (restaurant) {
          final cartItems = ref.watch(cartProvider);
          if (cartItems.isEmpty) return null;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
              ],
            ),
            child: ElevatedButton(
              onPressed: () => context.go('/customer/cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${cartItems.length} items  |  View Cart',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                ],
              ),
            ),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}

enum _MenuListItemType { header, item }

class _MenuListItem {
  final _MenuListItemType type;
  final String? headerTitle;
  final _MenuItem? item;

  _MenuListItem.header(this.headerTitle)
      : type = _MenuListItemType.header,
        item = null;
  _MenuListItem.item(this.item)
      : type = _MenuListItemType.item,
        headerTitle = null;
}

class _MenuItem {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final FoodReel? reel;
  final FoodProduct? product;

  _MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.reel,
    this.product,
  });

  FoodReel toReel() {
    if (reel != null) return reel!;
    return FoodReel(
      id: product!.id,
      restaurantId: product!.restaurantId,
      videoUrl: product!.imageUrl,
      description: product!.description,
      dishName: product!.name,
      price: product!.price,
    );
  }
}

class _MenuCard extends ConsumerWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});

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
      return url.replaceAll(RegExp(r'\.(mp4|mov|avi|mkv|webm)$'), '.jpg');
    }

    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.radio_button_checked,
                    color: Colors.green, size: 16),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _getDisplayImage(item.imageUrl),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[100],
                        child: const Icon(Icons.fastfood,
                            color: Colors.deepOrange),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).addItem(item.toReel());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} added to cart!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.grey[300]!),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('ADD',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
