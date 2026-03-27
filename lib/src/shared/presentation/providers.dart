import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories.dart';
import '../../features/shared/domain/models.dart';

// Repositories
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return FirestoreRestaurantRepository();
});

final reelRepositoryProvider = Provider<ReelRepository>((ref) {
  return FirestoreReelRepository();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirestoreOrderRepository();
});

final foodProductRepositoryProvider = Provider<FoodProductRepository>((ref) {
  return FirestoreFoodProductRepository();
});

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return FirestoreOfferRepository();
});

// Data Providers
final reelsProvider = FutureProvider<List<FoodReel>>((ref) async {
  final repository = ref.watch(reelRepositoryProvider);
  return repository.getReels();
});

final reelsStreamProvider = StreamProvider<List<FoodReel>>((ref) {
  final repository = ref.watch(reelRepositoryProvider);
  return repository.getReelsStream();
});

final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getRestaurants();
});

final restaurantsStreamProvider = StreamProvider<List<Restaurant>>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getRestaurantsStream();
});

final allProductsStreamProvider = StreamProvider<List<FoodProduct>>((ref) {
  final repository = ref.watch(foodProductRepositoryProvider);
  return repository.getAllProductsStream();
});

// Specific Providers
final restaurantProvider =
    FutureProvider.family<Restaurant, String>((ref, id) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getRestaurant(id);
});

final customerOrdersProvider =
    FutureProvider.family<List<Order>, String>((ref, userId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrders(userId, 'customer');
});

final customerOrdersStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, userId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrdersStream(userId, 'customer');
});

final restaurantOrdersProvider =
    FutureProvider.family<List<Order>, String>((ref, restaurantId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrders(restaurantId, 'restaurant');
});

final restaurantOrdersStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, restaurantId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrdersStream(restaurantId, 'restaurant');
});

final foodProductsProvider =
    FutureProvider.family<List<FoodProduct>, String>((ref, restaurantId) async {
  final repository = ref.watch(foodProductRepositoryProvider);
  return repository.getProducts(restaurantId);
});

final offersProvider =
    FutureProvider.family<List<Offer>, String>((ref, restaurantId) async {
  final repository = ref.watch(offerRepositoryProvider);
  return repository.getOffers(restaurantId);
});

final restaurantReelsProvider =
    FutureProvider.family<List<FoodReel>, String>((ref, restaurantId) async {
  final repository = ref.watch(reelRepositoryProvider);
  return repository.getReelsByRestaurant(restaurantId);
});
