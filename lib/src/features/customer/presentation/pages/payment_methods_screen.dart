import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:uuid/uuid.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final _labelController = TextEditingController();
  final _providerController = TextEditingController();
  final _lastFourController = TextEditingController();
  String _type = 'Card';

  @override
  void dispose() {
    _labelController.dispose();
    _providerController.dispose();
    _lastFourController.dispose();
    super.dispose();
  }

  void _showAddPaymentMethodDialog() {
    _labelController.clear();
    _providerController.clear();
    _lastFourController.clear();
    _type = 'Card';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (dialogContext, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Payment Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: ['Card', 'UPI', 'Wallet'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setModalState(() => _type = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Method Label (e.g., My Visa, Office UPI)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _providerController,
                decoration: const InputDecoration(labelText: 'Provider (e.g., Visa, HDFC, Google Pay)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastFourController,
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'Last 4 Digits / UPI ID hint', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                   onPressed: () {
                     if (_labelController.text.isNotEmpty && _providerController.text.isNotEmpty) {
                       final newMethod = PaymentMethod(
                         id: const Uuid().v4(),
                         type: _type,
                         label: _labelController.text,
                         provider: _providerController.text,
                         lastFour: _lastFourController.text,
                       );
                       ref.read(authProvider.notifier).addPaymentMethod(newMethod);
                       Navigator.pop(dialogContext);
                     }
                   },
                   style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.deepOrange,
                       minimumSize: const Size.fromHeight(50)),
                   child: const Text('Add Payment Method'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final methods = user?.paymentMethods ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: methods.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment_outlined, size: 66, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No payment methods added'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddPaymentMethodDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                    child: const Text('Add Method'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final method = methods[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
                      child: Icon(_getIconForType(method.type), color: Colors.deepOrange),
                    ),
                    title: Text(method.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${method.provider} | **** ${method.lastFour}'),
                    trailing: IconButton(
                       icon: const Icon(Icons.delete_outline, color: Colors.grey),
                       onPressed: () => ref.read(authProvider.notifier).removePaymentMethod(method.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentMethodDialog,
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'card': return Icons.credit_card_outlined;
      case 'upi': return Icons.account_balance_outlined;
      case 'wallet': return Icons.account_balance_wallet_outlined;
      default: return Icons.payment_outlined;
    }
  }
}
