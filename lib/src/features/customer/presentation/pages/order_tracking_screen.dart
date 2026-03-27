import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:food_reel_app/src/features/customer/presentation/widgets/customer_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final ordersAsync = authState.user != null
        ? ref.watch(customerOrdersStreamProvider(authState.user!.id))
        : const AsyncValue<List<Order>>.loading();

    // Listen for order updates to notify customer of delays
    if (authState.user != null) {
      ref.listen(customerOrdersStreamProvider(authState.user!.id), (previous, next) {
        if (previous is AsyncData<List<Order>> && next is AsyncData<List<Order>>) {
          for (final nextOrder in next.value) {
            try {
              final prevOrder = previous.value.firstWhere((o) => o.id == nextOrder.id);
              if (nextOrder.requestedExtraTime != prevOrder.requestedExtraTime && 
                  nextOrder.requestedExtraTime != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Update: Restaurant requested +${nextOrder.requestedExtraTime} mins for your order #${nextOrder.id.substring(0, 5)}'),
                    backgroundColor: Colors.orange[800],
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            } catch (e) {
              // New order, ignore
            }
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://cdn-icons-png.flaticon.com/512/3500/3500833.png',
                    width: 150,
                    height: 150,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No orders yet!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  const Text('Place your first order now'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/customer/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Start Exploring'),
                  ),
                ],
              ),
            );
          }

          final activeOrders = orders
              .where((o) =>
                  o.status != OrderStatus.delivered &&
                  o.status != OrderStatus.cancelled)
              .toList();
          final pastOrders = orders
              .where((o) =>
                  o.status == OrderStatus.delivered ||
                  o.status == OrderStatus.cancelled)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _OrdersListView(orders: activeOrders, isActive: true),
              _OrdersListView(orders: pastOrders, isActive: false),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 3),
    );
  }
}

class _OrdersListView extends StatelessWidget {
  final List<Order> orders;
  final bool isActive;

  const _OrdersListView({required this.orders, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(isActive ? 'No active orders' : 'No completed orders'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _OrderCard(order: orders[index], isActive: isActive);
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  final bool isActive;

  const _OrderCard({required this.order, required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need the restaurant name, ideally we should have it in the order or fetch it
    final restaurantAsync = ref.watch(restaurantProvider(order.restaurantId));

    return restaurantAsync.when(
      data: (restaurant) => _buildCard(context, ref, restaurant),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
            child: SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()))),
      ),
      error: (_, __) => _buildCard(context, ref, null),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Restaurant? restaurant) {
    final statusColor = _getStatusColor(order.status);
    final statusText = order.status.name
        .toUpperCase()
        .replaceAll('FORDELIVERY', ' FOR DELIVERY');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    restaurant?.imageUrl ??
                        'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=200',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant?.name ?? 'Restaurant',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isActive) ...[
                                  _PulsingDot(color: statusColor),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  statusText,
                                  style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Payment Status
                          if (order.paymentMethod == 'Online')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 10),
                                  SizedBox(width: 4),
                                  Text(
                                    'Paid Online',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.payments_outlined,
                                      color: Colors.blue, size: 10),
                                  SizedBox(width: 4),
                                  Text(
                                    'COD',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text(
                        restaurant?.location ?? 'Location',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (order.currentTotal != order.totalAmount) ...[
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '₹${order.currentTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                            ),
                          ] else
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          Text(
                            ' | ${DateFormat('dd MMM yyyy, hh:mm a').format(order.timestamp)}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 ...order.items.map((item) => Padding(
                       padding: const EdgeInsets.only(bottom: 4),
                       child: Row(
                         children: [
                           Icon(
                             item.isCancelled
                                 ? Icons.cancel_outlined
                                 : Icons.radio_button_checked,
                             color: item.isCancelled ? Colors.red : Colors.green,
                             size: 12,
                           ),
                           const SizedBox(width: 8),
                           Text(
                             '${item.reel.dishName} x ${item.quantity}',
                             style: TextStyle(
                               color: item.isCancelled
                                   ? Colors.grey
                                   : Colors.grey[700],
                               fontSize: 13,
                               decoration: item.isCancelled
                                   ? TextDecoration.lineThrough
                                   : null,
                             ),
                           ),
                           const Spacer(),
                           if (!item.isCancelled && order.status == OrderStatus.pending)
                             TextButton(
                               onPressed: () => _cancelItem(ref, order.id, item.reel.id),
                               style: TextButton.styleFrom(
                                 padding: const EdgeInsets.symmetric(horizontal: 8),
                                 minimumSize: Size.zero,
                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                               ),
                               child: const Text('Cancel Item', style: TextStyle(color: Colors.red, fontSize: 11)),
                             ),
                           if (item.isCancelled && order.status == OrderStatus.pending)
                             TextButton(
                               onPressed: () => _cancelItem(ref, order.id, item.reel.id),
                               style: TextButton.styleFrom(
                                 padding: const EdgeInsets.symmetric(horizontal: 8),
                                 minimumSize: Size.zero,
                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                               ),
                               child: const Text('Restore Item', style: TextStyle(color: Colors.blue, fontSize: 11)),
                             ),
                           if (item.isCancelled && order.status != OrderStatus.pending) ...[
                             const SizedBox(width: 8),
                             const Text(
                               '(Cancelled)',
                               style: TextStyle(
                                   color: Colors.red,
                                   fontSize: 10,
                                   fontWeight: FontWeight.bold),
                             ),
                           ],
                         ],
                       ),
                     )),
              ],
            ),
          ),
          if (isActive)
            _buildTrackingSection(context, ref)
          else
            _buildPastOrderButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildTrackingSection(BuildContext context, WidgetRef ref) {
    final canCancel = order.status == OrderStatus.pending || 
                      order.status == OrderStatus.preparing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 18, color: Colors.deepOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getEstimatedTimeText(),
                      style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    if (order.requestedExtraTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Restaurant requested ${order.requestedExtraTime} mins more',
                          style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.deepOrange),
            ],
          ),
          const SizedBox(height: 12),
          // Mini Step Progress
          Row(
            children: List.generate(4, (index) {
              final isCompleted = _isStepCompleted(index, order.status);
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.deepOrange : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          if (canCancel) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showCancelConfirmation(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('CANCEL ORDER', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO, KEEP IT'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, 'cancelled');
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled successfully')),
                );
              }
            },
            child: const Text('YES, CANCEL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPastOrderButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (order.rating != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${order.rating} | ${order.review ?? ""}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('REORDER',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showRatingDialog(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange,
                    elevation: 0,
                    side: const BorderSide(color: Colors.deepOrange),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(order.rating == null ? 'RATE ORDER' : 'EDIT RATING',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, WidgetRef ref) {
    double selectedRating = order.rating ?? 5.0;
    final reviewController = TextEditingController(text: order.review);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate your order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  hintText: 'Write a review (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(orderRepositoryProvider).rateOrder(
                  order.id,
                  selectedRating,
                  reviewController.text,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  String _getEstimatedTimeText() {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Waiting for restaurant confirmation';
      case OrderStatus.preparing:
        return 'Food is being prepared';
      case OrderStatus.ready:
        return 'Food is ready for pickup';
      case OrderStatus.outForDelivery:
        return 'Valet is on the way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool _isStepCompleted(int index, OrderStatus status) {
    final statusIndex = _getStatusIndex(status);
    return index <= statusIndex;
  }

  int _getStatusIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.ready:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.purple;
      case OrderStatus.outForDelivery:
        return Colors.deepOrange;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  void _cancelItem(WidgetRef ref, String orderId, String reelId) async {
    try {
      await ref.read(orderRepositoryProvider).cancelOrderItem(orderId, reelId);
    } catch (e) {
      // Error handled by repo or listener
    }
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
