import '../../features/shared/domain/models.dart';
import 'repositories.dart';
import '../../features/shared/data/dummy_data.dart';
import 'package:uuid/uuid.dart';

class DatabaseSeeder {
  final RestaurantRepository restaurantRepo;
  final ReelRepository reelRepo;
  final OrderRepository orderRepo;

  DatabaseSeeder({
    required this.restaurantRepo,
    required this.reelRepo,
    required this.orderRepo,
  });

  Future<void> seedAll(String currentUserId) async {
    await seedRestaurants();
    await seedReels();
    await seedOrders(currentUserId);
  }

  Future<void> seedRestaurants() async {
    try {
      for (final restaurant in DummyData.restaurants) {
        await restaurantRepo.addRestaurant(restaurant);
      }
    } catch (e) {
      print('Error seeding restaurants: $e');
    }
  }

  Future<void> seedReels() async {
    try {
      for (final reel in DummyData.reels) {
        await reelRepo.addReel(reel);
      }
    } catch (e) {
      print('Error seeding reels: $e');
    }
  }

  Future<void> seedOrders(String currentUserId) async {
    try {
      // Create a sample order
      final sampleOrder = Order(
        id: const Uuid().v4(),
        customerId: currentUserId,
        restaurantId: 'r1',
        items: [
          CartItem(
            reel: DummyData.reels[0],
            quantity: 2,
          ),
        ],
        totalAmount: (DummyData.reels[0].price * 2) +
            20 + // Packaging
            40 + // Delivery
            (((DummyData.reels[0].price * 2) + 20) * 0.05),
        status: OrderStatus.delivered,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        estimatedDelivery: DateTime.now(),
        deliveryAddress: 'Sample Address',
        trackingId: const Uuid().v4(),
      );
      await orderRepo.createOrder(sampleOrder);
    } catch (e) {
      print('Error seeding orders: $e');
    }
  }

  Future<void> clearSeededData() async {
    const ids = [
      "1mYExPlmYlPLQ4uSmrTjmgBEmyq2",
      "DZvDtnfCOVMB3xunvHTZux07Dfg1",
      "lwlA0OISjrZneZ7DG5izM6nQsho2",
    ];

    try {
      for (final id in ids) {
        await restaurantRepo.deleteRestaurant(id);
      }
    } catch (e) {
      print('Error clearing seeded data: $e');
    }
  }

  Future<void> seedSpecificRestaurant(String id) async {
    try {
      final newResto = Restaurant(
        id: id,
        ownerId: id,
        name: "Resto $id",
        description: "Fresh and delicious food served daily.",
        address: "Arikkulam Area",
        location: "Arikkulam",
        rating: 4.5,
        imageUrl:
            "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80",
        cuisine: "Multi-Cuisine",
        phone: "+91 9000000000",
        deliveryCharge: 40,
        deliveryTime: 34,
        minOrderValue: 130,
        distance: "2.8 km",
      );
      await restaurantRepo.addRestaurant(newResto);

      final reel1 = FoodReel(
        id: const Uuid().v4(),
        restaurantId: id,
        videoUrl:
            "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
        dishName: "House Special Biryani",
        description:
            "Our signature dish, made with love and fresh ingredients.",
        price: 250,
        likes: 120,
        category: AppCategories.biryani,
      );
      await reelRepo.addReel(reel1);
    } catch (e) {
      print('Error seeding specific restaurant: $e');
    }
  }
}
