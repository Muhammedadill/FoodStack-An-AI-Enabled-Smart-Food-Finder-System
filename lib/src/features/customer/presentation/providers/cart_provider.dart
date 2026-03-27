import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(FoodReel reel) {
    final existingIndex = state.indexWhere((item) => item.reel.id == reel.id);
    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      final updatedItem = CartItem(
        reel: existingItem.reel,
        quantity: existingItem.quantity + 1,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(reel: reel, quantity: 1)];
    }
  }

  void removeItem(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
    } else {
      final item = state[index];
      final updatedItem = CartItem(
        reel: item.reel,
        quantity: quantity,
      );
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    }
  }

  void clear() {
    state = [];
  }

  double get subtotal => state.fold(0.0, (sum, item) => sum + item.total);
  double get packagingCharge => 0.0; // Removed as requested
  double get gst =>
      (subtotal + packagingCharge) * 0.05; // 5% GST on food + packaging
  double get deliveryCharge =>
      state.isEmpty ? 0.0 : 40.0; // Base delivery charge
  double get total => subtotal + packagingCharge + gst + deliveryCharge;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
