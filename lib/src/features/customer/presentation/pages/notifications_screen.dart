import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _offers = true;
  bool _newRestaurants = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          _buildNotificationSection(
            'Order Notifications',
             [
               _buildSwitchTile('Order Updates', 'Receive updates on your order status', _orderUpdates, (val) => setState(() => _orderUpdates = val)),
             ]
          ),
          const Divider(),
          _buildNotificationSection(
            'Promotional Notifications',
             [
               _buildSwitchTile('Promotions & Deals', 'Get notified about general sales and events', _promotions, (val) => setState(() => _promotions = val)),
               _buildSwitchTile('Personalized Offers', 'Receive offers based on your preferences', _offers, (val) => setState(() => _offers = val)),
               _buildSwitchTile('New Restaurants', 'Be the first to know about new arrivals', _newRestaurants, (val) => setState(() => _newRestaurants = val)),
             ]
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      activeColor: Colors.deepOrange,
      value: value,
      onChanged: onChanged,
    );
  }
}
