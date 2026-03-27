import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';

import 'package:food_reel_app/src/shared/presentation/providers.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reelsAsync = ref.watch(reelsStreamProvider);
    final restaurantsAsync = ref.watch(restaurantsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            const Text(
              'System Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                reelsAsync.when(
                  data: (reels) => _buildStatCard('Total Reels',
                      '${reels.length}', Icons.play_circle_fill, Colors.orange),
                  loading: () => _buildStatCard('Total Reels', '...',
                      Icons.play_circle_fill, Colors.orange),
                  error: (_, __) => _buildStatCard('Total Reels', '0',
                      Icons.play_circle_fill, Colors.orange),
                ),
                restaurantsAsync.when(
                  data: (restaurants) => _buildStatCard('Total Restaurants',
                      '${restaurants.length}', Icons.restaurant, Colors.purple),
                  loading: () => _buildStatCard('Total Restaurants', '...',
                      Icons.restaurant, Colors.purple),
                  error: (_, __) => _buildStatCard('Total Restaurants', '0',
                      Icons.restaurant, Colors.purple),
                ),
                // Note: Real orders count would come from a dedicated order provider,
                // but we'll show a sample for now or use orderRepo if available.
                _buildStatCard(
                    'Total Orders', '12', Icons.shopping_bag, Colors.green),
                _buildStatCard('Active Users', '5', Icons.people, Colors.blue),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              context,
              'Verify Restaurants',
              'Review and manage restaurant registrations',
              Icons.verified_user,
              () {
                context.push('/admin/restaurant-management');
              },
            ),
            _buildActionItem(
              context,
              'Manage Content',
              'Monitor and moderate food reels',
              Icons.movie_filter,
              () {
                context.push('/admin/reel-management');
              },
            ),
            _buildActionItem(
              context,
              'User Management',
              'Manage customer and restaurant accounts',
              Icons.manage_accounts,
              () {
                context.push('/admin/user-management');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
          child: Icon(icon, color: Colors.deepOrange),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
