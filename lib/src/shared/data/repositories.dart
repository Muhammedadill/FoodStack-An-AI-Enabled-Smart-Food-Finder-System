import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:food_reel_app/src/features/shared/domain/models.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants();
  Stream<List<Restaurant>> getRestaurantsStream();
  Future<Restaurant> getRestaurant(String id);
  Future<void> addRestaurant(Restaurant restaurant);
  Future<void> updateRestaurant(Restaurant restaurant);
  Future<void> deleteRestaurant(String id);
}

abstract class ReelRepository {
  Future<List<FoodReel>> getReels();
  Stream<List<FoodReel>> getReelsStream();
  Future<List<FoodReel>> getReelsByRestaurant(String restaurantId);
  Future<void> addReel(FoodReel reel);
  Future<void> updateReel(FoodReel reel);
  Future<void> deleteReel(String id);
}

abstract class OrderRepository {
  Future<List<Order>> getOrders(String userId, String role);
  Stream<List<Order>> getOrdersStream(String userId, String role);
  Future<void> createOrder(Order order);
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> rateOrder(String orderId, double rating, String review);
  Future<void> requestExtraTime(String orderId, int minutes);
  Future<void> cancelOrderItem(String orderId, String reelId);
}

abstract class FoodProductRepository {
  Future<List<FoodProduct>> getProducts(String restaurantId);
  Future<void> addProduct(FoodProduct product);
  Future<void> updateProduct(FoodProduct product);
  Future<void> deleteProduct(String id);
  Stream<List<FoodProduct>> getAllProductsStream();
}

abstract class OfferRepository {
  Future<List<Offer>> getOffers(String restaurantId);
  Future<void> addOffer(Offer offer);
  Future<void> updateOffer(Offer offer);
  Future<void> deleteOffer(String id);
}

class FirestoreRestaurantRepository implements RestaurantRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  final String _collection = 'restaurants';

  @override
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Restaurant.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<Restaurant>> getRestaurantsStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Restaurant.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<Restaurant> getRestaurant(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Restaurant not found');
    return Restaurant.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addRestaurant(Restaurant restaurant) async {
    await _db
        .collection(_collection)
        .doc(restaurant.id)
        .set(restaurant.toMap());
  }

  @override
  Future<void> updateRestaurant(Restaurant restaurant) async {
    await _db
        .collection(_collection)
        .doc(restaurant.id)
        .update(restaurant.toMap());
  }

  @override
  Future<void> deleteRestaurant(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

class FirestoreReelRepository implements ReelRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  final String _collection = 'reels';

  @override
  Future<List<FoodReel>> getReels() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      return snapshot.docs
          .map((doc) => FoodReel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<FoodReel>> getReelsStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodReel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<List<FoodReel>> getReelsByRestaurant(String restaurantId) async {
    final snapshot = await _db
        .collection(_collection)
        .where('restaurantId', isEqualTo: restaurantId)
        .get();
    return snapshot.docs
        .map((doc) => FoodReel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addReel(FoodReel reel) async {
    await _db.collection(_collection).doc(reel.id).set(reel.toMap());
  }

  @override
  Future<void> updateReel(FoodReel reel) async {
    await _db.collection(_collection).doc(reel.id).update(reel.toMap());
  }

  @override
  Future<void> deleteReel(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

class FirestoreOrderRepository implements OrderRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  final String _collection = 'orders';

  @override
  Future<List<Order>> getOrders(String userId, String role) async {
    try {
      Query query = _db.collection(_collection);
      if (role == 'customer') {
        query = query.where('customerId', isEqualTo: userId);
      } else if (role == 'restaurant') {
        query = query.where('restaurantId', isEqualTo: userId);
      }
      final snapshot = await query.orderBy('timestamp', descending: true).get();
      return snapshot.docs
          .map((doc) =>
              Order.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<Order>> getOrdersStream(String userId, String role) {
    Query query = _db.collection(_collection);
    if (role == 'customer') {
      query = query.where('customerId', isEqualTo: userId);
    } else if (role == 'restaurant') {
      query = query.where('restaurantId', isEqualTo: userId);
    }

    return query
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Order.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  @override
  Future<void> createOrder(Order order) async {
    await _db.collection(_collection).doc(order.id).set(order.toMap());
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection(_collection).doc(orderId).update({'status': status});
  }

  @override
  Future<void> rateOrder(String orderId, double rating, String review) async {
    await _db.collection(_collection).doc(orderId).update({
      'rating': rating,
      'review': review,
    });
  }

  @override
  Future<void> requestExtraTime(String orderId, int minutes) async {
    await _db.collection(_collection).doc(orderId).update({
      'requestedExtraTime': minutes,
    });
  }

  @override
  Future<void> cancelOrderItem(String orderId, String reelId) async {
    final doc = await _db.collection(_collection).doc(orderId).get();
    if (!doc.exists) return;

    final order = Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    final updatedItems = order.items.map((item) {
      if (item.reel.id == reelId) {
        return item.copyWith(isCancelled: !item.isCancelled);
      }
      return item;
    }).toList();

    // Check if all items are cancelled
    final allCancelled = updatedItems.every((item) => item.isCancelled);
    String status = order.status.toString();

    if (allCancelled) {
      status = OrderStatus.cancelled.toString();
    } else if (order.status == OrderStatus.cancelled) {
      // If was cancelled but now has active items, revert to pending
      status = OrderStatus.pending.toString();
    }

    // Recalculate total amount if needed (optional, depends on policy)
    // For now, let's keep totalAmount as original but maybe logic uses available total?
    // Let's add availableTotal to Order model later if needed.

    await _db.collection(_collection).doc(orderId).update({
      'items': updatedItems
          .map((i) => {
                'reel': i.reel.toMap(),
                'quantity': i.quantity,
                'isCancelled': i.isCancelled,
              })
          .toList(),
      'status': status,
    });
  }
}

class FirestoreFoodProductRepository implements FoodProductRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  final String _collection = 'food_products';

  @override
  Future<List<FoodProduct>> getProducts(String restaurantId) async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      return snapshot.docs
          .map((doc) => FoodProduct.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addProduct(FoodProduct product) async {
    await _db.collection(_collection).doc(product.id).set(product.toMap());
  }

  @override
  Future<void> updateProduct(FoodProduct product) async {
    await _db.collection(_collection).doc(product.id).update(product.toMap());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  @override
  Stream<List<FoodProduct>> getAllProductsStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodProduct.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}

class FirestoreOfferRepository implements OfferRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  final String _collection = 'offers';

  @override
  Future<List<Offer>> getOffers(String restaurantId) async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      return snapshot.docs
          .map((doc) => Offer.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addOffer(Offer offer) async {
    await _db.collection(_collection).doc(offer.id).set(offer.toMap());
  }

  @override
  Future<void> updateOffer(Offer offer) async {
    await _db.collection(_collection).doc(offer.id).update(offer.toMap());
  }

  @override
  Future<void> deleteOffer(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
