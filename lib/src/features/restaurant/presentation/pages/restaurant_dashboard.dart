import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/manage_food_products_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/order_management_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/manage_offers_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/manage_reels_screen.dart';

/// Main restaurant shell with bottom navigation
class RestaurantDashboard extends ConsumerStatefulWidget {
  const RestaurantDashboard({super.key});

  @override
  ConsumerState<RestaurantDashboard> createState() =>
      _RestaurantDashboardState();
}

class _RestaurantDashboardState extends ConsumerState<RestaurantDashboard> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    _HomeTab(),
    ManageFoodProductsScreen(),
    OrderManagementScreen(),
    ManageOffersScreen(),
    ManageReelsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: Colors.deepPurple.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.deepPurple),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: Colors.deepPurple),
            label: 'Food Items',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Colors.deepPurple),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer, color: Colors.deepPurple),
            label: 'Offers',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library, color: Colors.deepPurple),
            label: 'Reels',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Home Tab — Dashboard overview
// ─────────────────────────────────────────────
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final ordersAsync = ref.watch(restaurantOrdersProvider(user.id));
    final productsAsync = ref.watch(foodProductsProvider(user.id));
    final reelsAsync = ref.watch(restaurantReelsProvider(user.id));
    final offersAsync = ref.watch(offersProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Stack'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user.name}! 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your restaurant from here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Row 1: Orders & Sales
            Row(
              children: [
                Expanded(
                  child: ordersAsync.when(
                    data: (orders) {
                      final active = orders
                          .where((o) => o.status != OrderStatus.delivered)
                          .length;
                      return _StatCard(
                        title: 'Active Orders',
                        value: '$active',
                        icon: Icons.receipt_long,
                        color: Colors.blue,
                      );
                    },
                    loading: () => const _StatCard(
                        title: 'Active Orders',
                        value: '...',
                        icon: Icons.receipt_long,
                        color: Colors.blue),
                    error: (_, __) => const _StatCard(
                        title: 'Active Orders',
                        value: '0',
                        icon: Icons.receipt_long,
                        color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ordersAsync.when(
                    data: (orders) {
                      final sales = orders.fold(0.0, (sum, o) => sum + o.total);
                      return _StatCard(
                        title: 'Total Sales',
                        value: '₹${sales.toStringAsFixed(0)}',
                        icon: Icons.currency_rupee,
                        color: Colors.green,
                      );
                    },
                    loading: () => const _StatCard(
                        title: 'Total Sales',
                        value: '...',
                        icon: Icons.currency_rupee,
                        color: Colors.green),
                    error: (_, __) => const _StatCard(
                        title: 'Total Sales',
                        value: '₹0',
                        icon: Icons.currency_rupee,
                        color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Products & Reels
            Row(
              children: [
                Expanded(
                  child: productsAsync.when(
                    data: (p) => _StatCard(
                      title: 'Food Items',
                      value: '${p.length}',
                      icon: Icons.restaurant_menu,
                      color: Colors.orange,
                    ),
                    loading: () => const _StatCard(
                        title: 'Food Items',
                        value: '...',
                        icon: Icons.restaurant_menu,
                        color: Colors.orange),
                    error: (_, __) => const _StatCard(
                        title: 'Food Items',
                        value: '0',
                        icon: Icons.restaurant_menu,
                        color: Colors.orange),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: reelsAsync.when(
                    data: (r) => _StatCard(
                      title: 'Food Reels',
                      value: '${r.length}',
                      icon: Icons.video_library,
                      color: Colors.deepPurple,
                    ),
                    loading: () => const _StatCard(
                        title: 'Food Reels',
                        value: '...',
                        icon: Icons.video_library,
                        color: Colors.deepPurple),
                    error: (_, __) => const _StatCard(
                        title: 'Food Reels',
                        value: '0',
                        icon: Icons.video_library,
                        color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Offers & Rating
            Row(
              children: [
                Expanded(
                  child: offersAsync.when(
                    data: (o) {
                      final active = o.where((x) => x.isActive).length;
                      return _StatCard(
                        title: 'Active Offers',
                        value: '$active',
                        icon: Icons.local_offer,
                        color: Colors.red,
                      );
                    },
                    loading: () => const _StatCard(
                        title: 'Active Offers',
                        value: '...',
                        icon: Icons.local_offer,
                        color: Colors.red),
                    error: (_, __) => const _StatCard(
                        title: 'Active Offers',
                        value: '0',
                        icon: Icons.local_offer,
                        color: Colors.red),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _StatCard(
                    title: 'Rating',
                    value: '4.5 ⭐',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _ActionTile(
              icon: Icons.toggle_on,
              title: 'Food Availability',
              subtitle: 'Set which items are available today',
              color: Colors.teal,
              onTap: () => context.push('/restaurant/food-availability'),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.video_call,
              title: 'Upload New Reel',
              subtitle: 'Create a new food video reel',
              color: Colors.indigo,
              onTap: () => context.push('/restaurant/upload-reel'),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.store,
              title: 'Shop Profile',
              subtitle: 'Update your shop details and images',
              color: Colors.amber,
              onTap: () => context.push('/restaurant/profile'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddMenu(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Content',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.restaurant_menu, color: Colors.white),
                ),
                title: const Text('Add Food Product'),
                subtitle: const Text('Use image picker to select dish photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/restaurant/food-products');
                  // We can't directly open the dialog here easily without refactoring,
                  // but navigating to the page is a good step.
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepOrange,
                  child: Icon(Icons.videocam, color: Colors.white),
                ),
                title: const Text('Upload Food Reel'),
                subtitle: const Text('Use image picker to select dish video'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/restaurant/upload-reel');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
