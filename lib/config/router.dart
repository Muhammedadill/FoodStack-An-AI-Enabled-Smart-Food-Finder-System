import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';

// Screen imports using package imports for absolute consistency
import 'package:food_reel_app/src/features/auth/presentation/pages/login_screen.dart';
import 'package:food_reel_app/src/features/auth/presentation/pages/role_selection_screen.dart';
import 'package:food_reel_app/src/features/auth/presentation/pages/register_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/customer_home_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/explore_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/reels_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/restaurant_details_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/cart_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/order_tracking_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/checkout_payment_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/profile_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/edit_profile_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/saved_addresses_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/payment_methods_screen.dart';
import 'package:food_reel_app/src/features/customer/presentation/pages/notifications_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/restaurant_dashboard.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/upload_reel_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/order_management_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/manage_food_products_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/manage_offers_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/manage_reels_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/food_availability_screen.dart';
import 'package:food_reel_app/src/features/restaurant/presentation/pages/restaurant_profile_screen.dart';

import 'package:food_reel_app/src/features/admin/presentation/pages/admin_dashboard.dart';
import 'package:food_reel_app/src/features/admin/presentation/pages/user_management_screen.dart';
import 'package:food_reel_app/src/features/admin/presentation/pages/restaurant_management_screen.dart';
import 'package:food_reel_app/src/features/admin/presentation/pages/reel_management_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // If auth is not initialized, don't redirect yet
      if (!authState.isInitialized) {
        return null; // Stay on current route until initialized
      }

      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/role-selection' ||
          state.matchedLocation.startsWith('/register');
      final isSplash = state.matchedLocation == '/';

      debugPrint(
          'Router: isLoggedIn=$isLoggedIn, matchedLocation=${state.matchedLocation}');

      if (!isLoggedIn) {
        // Not logged in -> must be on auth pages
        if (isLoggingIn) return null;
        if (isSplash) return '/login';
        return '/login';
      }

      // Logged in -> should not be on auth pages or splash
      if (isLoggingIn || isSplash) {
        final user = authState.user!;
        debugPrint(
            'Router: Redirecting logged-in user ${user.email} (Role: ${user.role})');

        if (user.id == 'admin_id') return '/admin/dashboard';

        return user.role == UserRole.restaurant
            ? '/restaurant/dashboard'
            : '/customer/home';
      }

      return null;
    },
    routes: [
      // Auth Initial Loading Route (Splash)
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/register/:role',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'customer';
          return RegisterScreen(role: role);
        },
      ),

      // Flattened Admin Routes for better reliability
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/user-management',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/restaurant-management',
        builder: (context, state) => const RestaurantManagementScreen(),
      ),
      GoRoute(
        path: '/admin/reel-management',
        builder: (context, state) => const ReelManagementScreen(),
      ),

      // Customer Routes
      GoRoute(
        path: '/customer/home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/customer/explore',
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/customer/reels',
        builder: (context, state) => const ReelsScreen(),
      ),
      GoRoute(
        path: '/customer/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/customer/checkout',
        builder: (context, state) => const CheckoutPaymentScreen(),
      ),
      GoRoute(
        path: '/customer/order-tracking',
        builder: (context, state) => const OrderTrackingScreen(),
      ),
      GoRoute(
        path: '/customer/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/customer/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/customer/saved-addresses',
        builder: (context, state) => const SavedAddressesScreen(),
      ),
      GoRoute(
        path: '/customer/payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/customer/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Restaurant Routes
      GoRoute(
        path: '/restaurant/dashboard',
        builder: (context, state) => const RestaurantDashboard(),
      ),
      GoRoute(
        path: '/restaurant/upload-reel',
        builder: (context, state) => const UploadReelScreen(),
      ),
      GoRoute(
        path: '/restaurant/orders',
        builder: (context, state) => const OrderManagementScreen(),
      ),
      GoRoute(
        path: '/restaurant/food-products',
        builder: (context, state) => const ManageFoodProductsScreen(),
      ),
      GoRoute(
        path: '/restaurant/offers',
        builder: (context, state) => const ManageOffersScreen(),
      ),
      GoRoute(
        path: '/restaurant/reels',
        builder: (context, state) => const ManageReelsScreen(),
      ),
      GoRoute(
        path: '/restaurant/food-availability',
        builder: (context, state) => const FoodAvailabilityScreen(),
      ),

      GoRoute(
        path: '/restaurant/profile',
        builder: (context, state) => const RestaurantProfileScreen(),
      ),

      // This must be LAST among /restaurant routes (dynamic param)
      GoRoute(
        path: '/restaurant/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return RestaurantDetailsScreen(id: id);
        },
      ),
    ],
  );
});
