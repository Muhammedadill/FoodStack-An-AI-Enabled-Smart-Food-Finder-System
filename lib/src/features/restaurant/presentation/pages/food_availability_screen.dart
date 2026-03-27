import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';

class FoodAvailabilityScreen extends ConsumerWidget {
  const FoodAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    final productsAsync = ref.watch(foodProductsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Availability'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Mark All Available',
            onPressed: () => _toggleAll(ref, user.id, true),
          ),
          IconButton(
            icon: const Icon(Icons.cancel_outlined),
            tooltip: 'Mark All Unavailable',
            onPressed: () => _toggleAll(ref, user.id, false),
          ),
        ],
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
                    'No food items to manage',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add food items first from Manage Food Items',
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

          final availableCount = products.where((p) => p.isAvailable).length;
          final unavailableCount = products.length - availableCount;

          return Column(
            children: [
              // Summary bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.teal.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryChip(
                      label: 'Total',
                      count: products.length,
                      color: Colors.teal,
                    ),
                    _SummaryChip(
                      label: 'Available',
                      count: availableCount,
                      color: Colors.green,
                    ),
                    _SummaryChip(
                      label: 'Unavailable',
                      count: unavailableCount,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${entry.value.where((p) => p.isAvailable).length}/${entry.value.length} available',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...entry.value.map((product) => Card(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: SwitchListTile(
                                secondary: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: product.isVeg
                                          ? Colors.green
                                          : Colors.red,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: product.isVeg
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: product.isAvailable
                                        ? null
                                        : Colors.grey,
                                  ),
                                ),
                                subtitle: Text(
                                  '₹${product.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: product.isAvailable
                                        ? Colors.teal
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                value: product.isAvailable,
                                activeTrackColor: Colors.green,
                                onChanged: (val) async {
                                  final updated =
                                      product.copyWith(isAvailable: val);
                                  await ref
                                      .read(foodProductRepositoryProvider)
                                      .updateProduct(updated);
                                  ref.invalidate(foodProductsProvider(user.id));
                                },
                              ),
                            )),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _toggleAll(WidgetRef ref, String userId, bool available) async {
    final products =
        await ref.read(foodProductRepositoryProvider).getProducts(userId);
    final repo = ref.read(foodProductRepositoryProvider);
    for (final product in products) {
      if (product.isAvailable != available) {
        await repo.updateProduct(product.copyWith(isAvailable: available));
      }
    }
    ref.invalidate(foodProductsProvider(userId));
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}
