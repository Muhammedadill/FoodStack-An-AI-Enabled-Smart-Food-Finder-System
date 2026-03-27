import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
                backgroundColor: Color(0xFFFF4B3A),
                child: Icon(Icons.notifications, color: Colors.white)),
            title: Text('Order Status Update #${index + 1}'),
            subtitle: const Text('Your order is being prepared.'),
            trailing:
                const Text('2m ago', style: TextStyle(color: Colors.grey)),
          );
        },
      ),
    );
  }
}
