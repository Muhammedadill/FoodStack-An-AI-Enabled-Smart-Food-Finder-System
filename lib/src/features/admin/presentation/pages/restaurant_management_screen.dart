import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:food_reel_app/src/features/admin/presentation/widgets/seed_data_button.dart';

class RestaurantManagementScreen extends ConsumerStatefulWidget {
  const RestaurantManagementScreen({super.key});

  @override
  ConsumerState<RestaurantManagementScreen> createState() =>
      _RestaurantManagementScreenState();
}

class _RestaurantManagementScreenState
    extends ConsumerState<RestaurantManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Management'),
        actions: [
          const SeedDataButton(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Form for adding new restaurants would open here.')),
              );
            },
          ),
        ],
      ),
      body: restaurantsAsync.when(
        data: (restaurants) => RefreshIndicator(
          onRefresh: () => ref.refresh(restaurantsProvider.future),
          child: ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final r = restaurants[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(r.imageUrl),
                ),
                title: Text(r.name, overflow: TextOverflow.ellipsis),
                subtitle: Text('${r.rating} ★ • ${r.address}',
                    overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () async {
                        await ref
                            .read(restaurantRepositoryProvider)
                            .deleteRestaurant(r.id);
                        ref.invalidate(restaurantsProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
