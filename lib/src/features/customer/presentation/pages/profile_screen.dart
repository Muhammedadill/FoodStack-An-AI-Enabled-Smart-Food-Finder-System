import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/customer/presentation/widgets/customer_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final userEmail = user?.email ?? 'Not logged in';
    final userName = user?.name ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Center(
              child: Stack(
                children: [
                   CircleAvatar(
                     radius: 60,
                     backgroundColor: Colors.deepOrange,
                     child: CircleAvatar(
                       radius: 56,
                       backgroundImage: NetworkImage(user?.profileImageUrl ??
                           'https://api.dicebear.com/7.x/avataaars/png?seed=${user?.name ?? 'Guest'}'),
                     ),
                   ),
                   Positioned(
                     bottom: 0,
                     right: 0,
                     child: CircleAvatar(
                       radius: 18,
                       backgroundColor: Colors.deepOrange,
                       child: IconButton(
                         padding: EdgeInsets.zero,
                         icon: const Icon(Icons.edit,
                             color: Colors.white, size: 18),
                         onPressed: () => context.push('/customer/edit-profile'),
                       ),
                     ),
                   ),
                 ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userEmail,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Stats or Quick Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Addresses', value: '${user?.addresses.length ?? 0}'),
                  const _StatItem(label: 'Reviews', value: '0'),
                  _StatItem(label: 'Payments', value: '${user?.paymentMethods.length ?? 0}'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile Options
            _buildProfileOption(
              context,
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => context.push('/customer/edit-profile'),
            ),
            _buildProfileOption(
              context,
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses',
              onTap: () => context.push('/customer/saved-addresses'),
            ),
            _buildProfileOption(
              context,
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () => context.push('/customer/payment-methods'),
            ),
            _buildProfileOption(
              context,
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () => context.push('/customer/notifications'),
            ),
            const Divider(height: 32, indent: 24, endIndent: 24),
            _buildProfileOption(
              context,
              icon: Icons.logout,
              title: 'Logout',
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 4),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              (iconColor ?? Theme.of(context).iconTheme.color ?? Colors.black)
                  .withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
