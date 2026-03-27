enum UserRole { customer, restaurant }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? profileImageUrl;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImageUrl,
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString(),
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'addresses': addresses.map((a) => a.toMap()).toList(),
      'paymentMethods': paymentMethods.map((p) => p.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] == 'UserRole.restaurant' || map['role'] == 'restaurant'
          ? UserRole.restaurant
          : UserRole.customer,
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      addresses: (map['addresses'] as List?)
              ?.map((a) => Address.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      paymentMethods: (map['paymentMethods'] as List?)
              ?.map((p) => PaymentMethod.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class Address {
  final String id;
  final String label;
  final String fullAddress;
  final String landmark;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.landmark = '',
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'landmark': landmark,
      'isDefault': isDefault,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      landmark: map['landmark'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
}

class PaymentMethod {
  final String id;
  final String type; // Card, UPI, etc.
  final String provider; // Visa, Google Pay, etc.
  final String lastFour;
  final String label;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.provider,
    required this.lastFour,
    required this.label,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'provider': provider,
      'lastFour': lastFour,
      'label': label,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      provider: map['provider'] ?? '',
      lastFour: map['lastFour'] ?? '',
      label: map['label'] ?? '',
    );
  }
}

// Alias for compatibility
typedef AppUser = User;

class AppCategories {
  static const starters = 'Starters';
  static const mainCourse = 'Main Course';
  static const biryani = 'Biryani';
  static const breads = 'Breads';
  static const rice = 'Rice';
  static const desserts = 'Desserts';
  static const beverages = 'Beverages';
  static const snacks = 'Snacks';
  static const comboMeals = 'Combo Meals';

  static const all = [
    starters,
    mainCourse,
    biryani,
    breads,
    rice,
    desserts,
    beverages,
    snacks,
    comboMeals,
  ];
}

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String location; // City/Area
  final double rating;
  final String imageUrl;
  final String ownerId;
  final String cuisine; // Type of cuisine
  final String phone;
  final bool isOpen;
  final double deliveryCharge;
  final int deliveryTime; // in minutes
  final double minOrderValue;
  final String distance;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.ownerId,
    required this.cuisine,
    required this.phone,
    this.isOpen = true,
    this.deliveryCharge = 40.0,
    this.deliveryTime = 30,
    this.minOrderValue = 100.0,
    this.distance = '2.5 km',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'location': location,
      'rating': rating,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'cuisine': cuisine,
      'phone': phone,
      'isOpen': isOpen,
      'deliveryCharge': deliveryCharge,
      'deliveryTime': deliveryTime,
      'minOrderValue': minOrderValue,
      'distance': distance,
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map, String id) {
    return Restaurant(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      cuisine: map['cuisine'] ?? '',
      phone: map['phone'] ?? '',
      isOpen: map['isOpen'] ?? true,
      deliveryCharge: (map['deliveryCharge'] ?? 40.0).toDouble(),
      deliveryTime: map['deliveryTime'] ?? 30,
      minOrderValue: (map['minOrderValue'] ?? 100.0).toDouble(),
      distance: map['distance'] ?? '2.5 km',
    );
  }
}

class FoodReel {
  final String id;
  final String restaurantId;
  final String
      videoUrl; // Using image URL as placeholder for now if no video support
  final String description;
  final String dishName;
  final double price;
  final int likes;
  final String category;

  const FoodReel({
    required this.id,
    required this.restaurantId,
    required this.videoUrl,
    required this.description,
    required this.dishName,
    required this.price,
    this.likes = 0,
    this.category = AppCategories.mainCourse,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'videoUrl': videoUrl,
      'description': description,
      'dishName': dishName,
      'price': price,
      'likes': likes,
      'category': category,
    };
  }

  factory FoodReel.fromMap(Map<String, dynamic> map, String id) {
    return FoodReel(
      id: id,
      restaurantId: map['restaurantId'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      description: map['description'] ?? '',
      dishName: map['dishName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      likes: map['likes'] ?? 0,
      category: map['category'] ?? AppCategories.mainCourse,
    );
  }
}

class CartItem {
  final FoodReel reel;
  int quantity;
  bool isCancelled;

  CartItem({
    required this.reel,
    this.quantity = 1,
    this.isCancelled = false,
  });

  double get total => reel.price * quantity;
  double get packagingCharge => 0.0; // Removed as requested
  double get gst =>
      (total + (packagingCharge / quantity)) *
      0.05; // 5% GST on food + split packing
  double get subtotal => total;

  CartItem copyWith({
    FoodReel? reel,
    int? quantity,
    bool? isCancelled,
  }) {
    return CartItem(
      reel: reel ?? this.reel,
      quantity: quantity ?? this.quantity,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}

enum OrderStatus {
  pending,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled
}

class Order {
  final String id;
  final String customerId;
  final String restaurantId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime timestamp;
  final DateTime? estimatedDelivery;
  final String? deliveryAddress;
  final String? trackingId;
  final String? paymentId;
  final String? paymentMethod;
  final double? rating;
  final String? review;
  final int? requestedExtraTime; // in minutes

  const Order({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.timestamp,
    this.estimatedDelivery,
    this.deliveryAddress,
    this.trackingId,
    this.paymentId,
    this.paymentMethod,
    this.rating,
    this.review,
    this.requestedExtraTime,
  });

  double get total => totalAmount;
  double get currentTotal {
    final activeItems = items.where((i) => !i.isCancelled).toList();
    if (activeItems.isEmpty) return 0.0;

    final subtotal = activeItems.fold(0.0, (sum, i) => sum + i.total);
    const packagingCharge = 0.0;
    final gst = (subtotal + packagingCharge) * 0.05;
    const deliveryCharge = 40.0;

    return subtotal + packagingCharge + gst + deliveryCharge;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'restaurantId': restaurantId,
      'items': items
          .map((i) => {
                'reel': i.reel.toMap(),
                'quantity': i.quantity,
                'isCancelled': i.isCancelled,
              })
          .toList(),
      'totalAmount': totalAmount,
      'status': status.toString(),
      'timestamp': timestamp.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'trackingId': trackingId,
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'rating': rating,
      'review': review,
      'requestedExtraTime': requestedExtraTime,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      customerId: map['customerId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      items: (map['items'] as List?)
              ?.map((i) => CartItem(
                    reel: FoodReel.fromMap(
                        i['reel'] as Map<String, dynamic>, i['reel']['id']),
                    quantity: i['quantity'] ?? 1,
                    isCancelled: i['isCancelled'] ?? false,
                  ))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: _parseOrderStatus(map['status'] ?? 'pending'),
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      estimatedDelivery: map['estimatedDelivery'] != null
          ? DateTime.parse(map['estimatedDelivery'])
          : null,
      deliveryAddress: map['deliveryAddress'],
      trackingId: map['trackingId'],
      paymentId: map['paymentId'],
      paymentMethod: map['paymentMethod'],
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      review: map['review'],
      requestedExtraTime: (map['requestedExtraTime'] as num?)?.toInt(),
    );
  }

  static OrderStatus _parseOrderStatus(String status) {
    switch (status) {
      case 'OrderStatus.pending':
      case 'pending':
        return OrderStatus.pending;
      case 'OrderStatus.preparing':
      case 'preparing':
        return OrderStatus.preparing;
      case 'OrderStatus.ready':
      case 'ready':
        return OrderStatus.ready;
      case 'OrderStatus.outForDelivery':
      case 'outForDelivery':
        return OrderStatus.outForDelivery;
      case 'OrderStatus.delivered':
      case 'delivered':
        return OrderStatus.delivered;
      case 'OrderStatus.cancelled':
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  Order copyWith({
    OrderStatus? status,
    DateTime? estimatedDelivery,
    double? rating,
    String? review,
    int? requestedExtraTime,
    List<CartItem>? items,
    double? totalAmount,
  }) {
    return Order(
      id: id,
      customerId: customerId,
      restaurantId: restaurantId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      timestamp: timestamp,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      deliveryAddress: deliveryAddress,
      trackingId: trackingId,
      paymentId: paymentId,
      paymentMethod: paymentMethod,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      requestedExtraTime: requestedExtraTime ?? this.requestedExtraTime,
    );
  }
}

class FoodProduct {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isVeg;
  final bool isAvailable;

  const FoodProduct({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl = '',
    this.isVeg = true,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isVeg': isVeg,
      'isAvailable': isAvailable,
    };
  }

  factory FoodProduct.fromMap(Map<String, dynamic> map, String id) {
    return FoodProduct(
      id: id,
      restaurantId: map['restaurantId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? AppCategories.mainCourse,
      imageUrl: map['imageUrl'] ?? '',
      isVeg: map['isVeg'] ?? true,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  FoodProduct copyWith({
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isVeg,
    bool? isAvailable,
  }) {
    return FoodProduct(
      id: id,
      restaurantId: restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isVeg: isVeg ?? this.isVeg,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class Offer {
  final String id;
  final String restaurantId;
  final String title;
  final String description;
  final double discountPercent;
  final String? productId; // null means applies to all
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;

  const Offer({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.productId,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'title': title,
      'description': description,
      'discountPercent': discountPercent,
      'productId': productId,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Offer.fromMap(Map<String, dynamic> map, String id) {
    return Offer(
      id: id,
      restaurantId: map['restaurantId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discountPercent: (map['discountPercent'] ?? 0.0).toDouble(),
      productId: map['productId'],
      validFrom:
          DateTime.parse(map['validFrom'] ?? DateTime.now().toIso8601String()),
      validUntil:
          DateTime.parse(map['validUntil'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
    );
  }

  Offer copyWith({
    String? title,
    String? description,
    double? discountPercent,
    String? productId,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? isActive,
  }) {
    return Offer(
      id: id,
      restaurantId: restaurantId,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercent: discountPercent ?? this.discountPercent,
      productId: productId ?? this.productId,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
    );
  }
}
