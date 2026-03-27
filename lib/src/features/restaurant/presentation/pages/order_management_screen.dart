import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() =>
      _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Login required')));
    }

    final ordersAsync = ref.watch(restaurantOrdersStreamProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: ordersAsync.when(
        data: (orders) => TabBarView(
          controller: _tabController,
          children: [
            _OrdersList(
                orders: orders
                    .where((o) => o.status == OrderStatus.pending)
                    .toList(),
                status: 'New'),
            _OrdersList(
                orders: orders
                    .where((o) => [
                          OrderStatus.preparing,
                          OrderStatus.ready,
                          OrderStatus.outForDelivery
                        ].contains(o.status))
                    .toList(),
                status: 'Active'),
            _OrdersList(
                orders: orders
                    .where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled)
                    .toList(),
                status: 'Completed'),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final List<Order> orders;
  final String status;

  const _OrdersList({required this.orders, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Text('No $status orders'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      order.timestamp.toString().substring(11, 16),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (order.paymentMethod == 'Online')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PAID ONLINE',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('CASH ON DELIVERY',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    if (order.status == OrderStatus.cancelled) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('CANCELLED',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const Divider(),
                ...order.items.map((i) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${i.quantity}x ${i.reel.dishName}',
                              style: TextStyle(
                                decoration: i.isCancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: i.isCancelled ? Colors.grey : null,
                              ),
                            ),
                          ),
                          if (!i.isCancelled &&
                              (order.status == OrderStatus.pending ||
                                  order.status == OrderStatus.preparing))
                            IconButton(
                              onPressed: () => _updateItemCancellation(
                                  ref, order.id, i.reel.id),
                              icon: const Icon(Icons.cancel_outlined,
                                  color: Colors.red, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Cancel item',
                            ),
                          if (i.isCancelled &&
                              (order.status == OrderStatus.pending ||
                                  order.status == OrderStatus.preparing))
                            IconButton(
                              onPressed: () => _updateItemCancellation(
                                  ref, order.id, i.reel.id),
                              icon: const Icon(Icons.undo,
                                  color: Colors.blue, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Restore item',
                            ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.currentTotal != order.total)
                          Text(
                            'Original: ₹${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 12),
                          ),
                        Text(
                          'Total: ₹${order.currentTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (order.status == OrderStatus.pending) ...[
                      TextButton(
                        onPressed: () =>
                            _updateStatus(ref, order.id, 'cancelled'),
                        child: const Text('Reject',
                            style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            _updateStatus(ref, order.id, 'preparing'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        child: const Text('Accept'),
                      ),
                    ] else if (order.status == OrderStatus.preparing) ...[
                      TextButton(
                        onPressed: () => _updateStatus(ref, order.id, 'cancelled'),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _showRequestTimeDialog(context, ref, order.id),
                        child: const Text('Delay', style: TextStyle(color: Colors.orange)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateStatus(ref, order.id, 'ready'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white),
                        child: const Text('Mark Ready'),
                      ),
                    ] else if (order.status == OrderStatus.ready)
                      ElevatedButton(
                        onPressed: () =>
                            _updateStatus(ref, order.id, 'outForDelivery'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white),
                        child: const Text('Mark Out for Delivery'),
                      )
                    else if (order.status == OrderStatus.outForDelivery)
                      ElevatedButton(
                        onPressed: () =>
                            _updateStatus(ref, order.id, 'delivered'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        child: const Text('Mark Delivered'),
                      ),
                  ],
                ),
                if (order.status == OrderStatus.delivered && order.rating != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Rating: ${order.rating} | ${order.review ?? "No review"}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (order.requestedExtraTime != null && order.status != OrderStatus.delivered)
                   Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Requested +${order.requestedExtraTime} mins more',
                      style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRequestTimeDialog(BuildContext context, WidgetRef ref, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request More Time'),
        content: const Text('Select how much extra time you need. The customer will be notified.'),
        actions: [5, 10, 15, 20].map((mins) => TextButton(
          onPressed: () async {
            try {
              await ref.read(orderRepositoryProvider).requestExtraTime(orderId, mins);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Wait time updated by +$mins mins'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } catch (e) {
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update time: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text('+$mins mins'),
        )).toList() + [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _updateStatus(WidgetRef ref, String orderId, String status) async {
    try {
      await ref.read(orderRepositoryProvider).updateOrderStatus(orderId, status);
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  void _updateItemCancellation(
      WidgetRef ref, String orderId, String reelId) async {
    try {
      await ref.read(orderRepositoryProvider).cancelOrderItem(orderId, reelId);
    } catch (e) {
      print('Error updating item cancellation: $e');
    }
  }
}
