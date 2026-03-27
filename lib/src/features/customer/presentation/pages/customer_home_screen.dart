import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:food_reel_app/src/features/customer/presentation/widgets/customer_bottom_nav.dart';
import 'package:food_reel_app/src/features/admin/presentation/widgets/seed_data_button.dart';
import 'package:go_router/go_router.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/category_listing_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  late TextEditingController _searchController;
  String _selectedLocation = 'Kozhikode City';
  String _searchQuery = '';
  String? _activeCategory;
  bool _showSearchResults = false;

  final List<String> kozhikodeLocations = [
    'Katangal',
    'Mukkam',
    'Kunnamangalam',
    'Kallamthode',
    'Kozhikode City',
    'Feroke',
    'Ramanattukara',
    'Koyilandy',
    'Vadakara',
    'Thalassery',
    'Kannur Road',
    'Kodiyeri',
    'Perambra',
    'Kakkodi',
    'Olavakkot',
    'Arikkulam',
    'Thiruvallur',
    'Kappad',
    'Beypore',
    'Kadalundi',
    'Valiyaparamba',
    'Payyoli',
    'Chalisgaon',
    'Nadapuram',
    'Vanimel',
    'Unnikulam',
    'Koduvally',
    'Koyilandy North',
    'Koyilandy South',
    'Thalassery North',
    'Thalassery South',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsStreamProvider);
    final reelsAsync = ref.watch(reelsStreamProvider);
    final productsAsync = ref.watch(allProductsStreamProvider);

    return Scaffold(
      body: _activeCategory != null
          ? Stack(
              children: [
                CategoryListingScreen(category: _activeCategory!),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => setState(() => _activeCategory = null),
                    ),
                  ),
                ),
              ],
            )
          : CustomScrollView(
              slivers: [
                // Header with Location and Search
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  toolbarHeight: 160,
                  titleSpacing: 0,
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Location Header
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.deepOrange,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showLocationPicker(context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _selectedLocation,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Kozhikode, Kerala',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.person_outline,
                                color: Colors.black,
                              ),
                              onPressed: () => context.go('/customer/profile'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value.toLowerCase();
                                      _showSearchResults = value.isNotEmpty;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search restaurants or food...',
                                    border: InputBorder.none,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _showSearchResults = false;
                                    });
                                  },
                                  child: const Icon(Icons.close,
                                      color: Colors.grey),
                                ),
                              const SizedBox(width: 8),
                              const Icon(Icons.mic_none,
                                  color: Colors.deepOrange),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Results or Regular Content
                if (_showSearchResults)
                  _buildSearchResults(restaurantsAsync, reelsAsync)
                else ...[
                  // Offer Slider
                  const SliverToBoxAdapter(child: _OfferSlider()),

                  // Categories "What's on your mind?"
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        "What's on your mind?",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 100,
                      ),
                      delegate: SliverChildListDelegate([
                        _buildMindItem(context, 'Starters', '🥗'),
                        _buildMindItem(context, 'Main Course', '🍽️'),
                        _buildMindItem(context, 'Biryani', '🍛'),
                        _buildMindItem(context, 'Breads', '🍞'),
                        _buildMindItem(context, 'Rice', '🍚'),
                        _buildMindItem(context, 'Desserts', '🍰'),
                        _buildMindItem(context, 'Beverages', '🥤'),
                        _buildMindItem(context, 'Snacks', '🥨'),
                        _buildMindItem(context, 'Combo Meals', '🍱'),
                      ]),
                    ),
                  ),

                  // Trending Reels
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        "Trending Dishes",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: restaurantsAsync.when(
                        data: (restaurants) => reelsAsync.when(
                          data: (reels) => productsAsync.when(
                            data: (products) {
                              final localRestaurantIds = restaurants
                                  .where((r) => r.location == _selectedLocation)
                                  .map((r) => r.id)
                                  .toSet();

                              // Combine reels and products
                              final List<FoodReel> combinedTrending = [];

                              // Add reels from local restaurants
                              combinedTrending.addAll(reels.where((r) =>
                                  localRestaurantIds.contains(r.restaurantId)));

                              // Add products as reels from local restaurants
                              for (final p in products) {
                                if (!localRestaurantIds
                                    .contains(p.restaurantId)) continue;
                                if (!combinedTrending.any((r) =>
                                    r.id == p.id ||
                                    r.dishName.toLowerCase() ==
                                        p.name.toLowerCase())) {
                                  combinedTrending.add(FoodReel(
                                    id: p.id,
                                    restaurantId: p.restaurantId,
                                    videoUrl: p.imageUrl,
                                    description: p.description,
                                    dishName: p.name,
                                    price: p.price,
                                    category: p.category,
                                    likes: 0,
                                  ));
                                }
                              }

                              // Sort: Likes first, then by name for products
                              combinedTrending.sort((a, b) {
                                if (b.likes != a.likes) {
                                  return b.likes.compareTo(a.likes);
                                }
                                return a.dishName.compareTo(b.dishName);
                              });

                              if (combinedTrending.isEmpty) {
                                return const Center(
                                    child: Text('No trends yet!'));
                              }

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: combinedTrending.length,
                                itemBuilder: (context, index) {
                                  final item = combinedTrending[index];
                                  return _TrendingDishCard(reel: item);
                                },
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (e, _) => Center(child: Text('Error: $e')),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: $e')),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),
                    ),
                  ),

                  // Nearby Restaurants
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        "Nearby Restaurants",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 330,
                      child: restaurantsAsync.when(
                        data: (restaurants) {
                          final nearbyRestaurants = restaurants
                              .where((r) => r.location == _selectedLocation)
                              .toList();

                          if (nearbyRestaurants.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            itemCount: nearbyRestaurants.length,
                            itemBuilder: (context, index) {
                              final restaurant = nearbyRestaurants[index];
                              return SizedBox(
                                width: 300,
                                child: _RestaurantCard(restaurant: restaurant),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),
                    ),
                  ),

                  // All Restaurants
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        "Restaurants to explore",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  restaurantsAsync.when(
                    data: (restaurants) {
                      final filteredRestaurants = restaurants
                          .where((r) => r.location == _selectedLocation)
                          .toList();

                      if (filteredRestaurants.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                              horizontal: 20,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No restaurants found in this location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try selecting a different location!',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                const SeedDataButton(),
                              ],
                            ),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final restaurant = filteredRestaurants[index];
                          return _RestaurantCard(restaurant: restaurant);
                        }, childCount: filteredRestaurants.length),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Colors.deepOrange),
                        ),
                      ),
                    ),
                    error: (e, _) => SliverToBoxAdapter(
                        child: Center(child: Text('Error: $e'))),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ],
            ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }

  Widget _buildSearchResults(
    AsyncValue<List<Restaurant>> restaurantsAsync,
    AsyncValue<List<FoodReel>> reelsAsync,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Results for "$_searchQuery"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              restaurantsAsync.when(
                data: (restaurants) {
                  final filtered = restaurants
                      .where((r) =>
                          r.name.toLowerCase().contains(_searchQuery) ||
                          r.cuisine.toLowerCase().contains(_searchQuery) ||
                          r.location.toLowerCase().contains(_searchQuery))
                      .toList();

                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('No restaurants found'),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurants (${filtered.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filtered.map((restaurant) =>
                          _SearchResultCard(restaurant: restaurant)),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              const SizedBox(height: 24),
              reelsAsync.when(
                data: (reels) {
                  final filtered = reels
                      .where((r) =>
                          r.dishName.toLowerCase().contains(_searchQuery) ||
                          r.description.toLowerCase().contains(_searchQuery))
                      .toList();

                  if (filtered.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Food Items (${filtered.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filtered.map((reel) => _FoodSearchCard(reel: reel)),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: kozhikodeLocations.length,
                itemBuilder: (context, index) {
                  final location = kozhikodeLocations[index];
                  return ListTile(
                    title: Text(location),
                    trailing: _selectedLocation == location
                        ? const Icon(Icons.check, color: Colors.deepOrange)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLocation = location;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMindItem(BuildContext context, String label, String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCategory = label;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TrendingDishCard extends StatelessWidget {
  final FoodReel reel;
  const _TrendingDishCard({required this.reel});

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('/video/upload/') ||
        lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.endsWith('.mkv');
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
  Widget build(BuildContext context) {
    final displayImage = _getDisplayImage(reel.videoUrl);

    return GestureDetector(
      onTap: () => context.push('/restaurant/${reel.restaurantId}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                displayImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.orange[50],
                  child: const Icon(Icons.fastfood, color: Colors.deepOrange),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.whatshot, color: Colors.deepOrange, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Trending',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reel.dishName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${reel.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${reel.likes}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    restaurant.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 20),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Free Delivery',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          minFontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${restaurant.rating}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AutoSizeText(
                    restaurant.address,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${restaurant.deliveryTime} min',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.currency_exchange,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '₹${restaurant.minOrderValue.toStringAsFixed(0)} min',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferSlider extends ConsumerStatefulWidget {
  const _OfferSlider();

  @override
  ConsumerState<_OfferSlider> createState() => _OfferSliderState();
}

class _OfferSliderState extends ConsumerState<_OfferSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsStreamProvider);

    return restaurantsAsync.when(
      data: (restaurants) {
        // Find our specific banner shops
        final bannerIds = [
          "1mYExPlmYlPLQ4uSmrTjmgBEmyq2", // Bake House
          "DZvDtnfCOVMB3xunvHTZux07Dfg1", // Smokys
          "lwlA0OISjrZneZ7DG5izM6nQsho2", // Yummy Fried Chicken
        ];

        final topShops =
            restaurants.where((r) => bannerIds.contains(r.id)).toList();

        // If no matches, fall back to any 3 restaurants
        final displayShops = topShops.isNotEmpty
            ? topShops
            : restaurants.take(3).toList();

        if (displayShops.isEmpty) return const SizedBox.shrink();

        final bannerColors = [
          '0xFFFF4B3A', // Orange-ish
          '0xFFFFB800', // Yellow
          '0xFF4CAF50', // Green
        ];

        return Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: displayShops.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final shop = displayShops[index];
                  final colorHex = bannerColors[index % bannerColors.length];
                  return AnimatedScale(
                    scale: _currentPage == index ? 1.0 : 0.95,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: () => context.push('/restaurant/${shop.id}'),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(shop.imageUrl),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.4),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(int.parse(colorHex)).withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Text(
                                shop.cuisine.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () =>
                                    context.push('/restaurant/${shop.id}'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'ORDER NOW',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                displayShops.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  height: 6,
                  width: _currentPage == index ? 20 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.deepOrange
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Restaurant restaurant;

  const _SearchResultCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                restaurant.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.restaurant),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisine,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.deliveryTime} min',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodSearchCard extends StatelessWidget {
  final FoodReel reel;

  const _FoodSearchCard({required this.reel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${reel.restaurantId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                reel.videoUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reel.dishName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reel.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${reel.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.deepOrange,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.favorite,
                              size: 14, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(
                            '${reel.likes}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
