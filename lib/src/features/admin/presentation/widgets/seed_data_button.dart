import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/shared/data/seeder.dart';

class SeedDataButton extends ConsumerWidget {
  const SeedDataButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Seed Full App Data'),
          onPressed: () async {
            final seeder = DatabaseSeeder(
              restaurantRepo: ref.read(restaurantRepositoryProvider),
              reelRepo: ref.read(reelRepositoryProvider),
              orderRepo: ref.read(orderRepositoryProvider),
            );

            final authData = ref.read(authProvider);
            final currentUserId = authData.user?.id ?? 'guest_user';

            try {
              await seeder.seedAll(currentUserId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔥 Successfully seeded ALL pages with data!'),
                    backgroundColor: Colors.green,
                  ),
                );
                ref.invalidate(restaurantsProvider);
                ref.invalidate(reelsProvider);
                ref.invalidate(customerOrdersProvider(currentUserId));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Error seeding data: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.delete_sweep, color: Colors.grey, size: 16),
          label: const Text(
            'Clear Seeded Restaurants',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          onPressed: () async {
            final seeder = DatabaseSeeder(
              restaurantRepo: ref.read(restaurantRepositoryProvider),
              reelRepo: ref.read(reelRepositoryProvider),
              orderRepo: ref.read(orderRepositoryProvider),
            );

            try {
              await seeder.clearSeededData();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🧹 Successfully cleared seeded restaurants!'),
                    backgroundColor: Colors.blueGrey,
                  ),
                );
                ref.invalidate(restaurantsProvider);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Error clearing data: $e')),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
