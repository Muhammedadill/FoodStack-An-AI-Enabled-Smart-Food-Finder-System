import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/presentation/providers.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isFirebaseConfigured;
  final bool isInitialized;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isFirebaseConfigured = true,
    this.isInitialized = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isFirebaseConfigured,
    bool? isInitialized,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFirebaseConfigured: isFirebaseConfigured ?? this.isFirebaseConfigured,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(AuthState()) {
    _init();
  }

  void _init() {
    debugPrint('AuthNotifier: Initializing auth state...');

    // 1. Failsafe: Initialize after 6 seconds regardless of Firebase/Firestore
    Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      if (!state.isInitialized) {
        debugPrint('AuthNotifier: Failsafe triggered, forcing initialization.');
        state = state.copyWith(isInitialized: true);
      }
    });

    // 2. Start Firebase listener immediately
    try {
      FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
        debugPrint(
            'AuthNotifier: Auth state change detected: ${firebaseUser?.email}');

        if (firebaseUser != null) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .get()
                .timeout(const Duration(seconds: 10));

            if (doc.exists) {
              final user = User.fromMap(doc.data()!, firebaseUser.uid);
              debugPrint(
                  'AuthNotifier: Profile loaded for ${user.email} (Role: ${user.role})');

              // Store role locally for faster persistence/routing
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_role', user.role.toString());

              state = state.copyWith(
                user: user,
                isInitialized: true,
              );
            } else {
              debugPrint(
                  'AuthNotifier: No Firestore document for ${firebaseUser.email}, defaulting to customer');
              state = state.copyWith(
                user: User(
                  id: firebaseUser.uid,
                  email: firebaseUser.email ?? '',
                  name: firebaseUser.displayName ?? 'User',
                  role: UserRole.customer,
                ),
                isInitialized: true,
              );
            }
          } catch (e) {
            debugPrint('AuthNotifier: Firestore fetch failed or timed out: $e');
            // Fallback: Use basic Firebase info if Firestore is down
            state = state.copyWith(
              user: User(
                id: firebaseUser.uid,
                email: firebaseUser.email ?? '',
                name: firebaseUser.displayName ?? 'User',
                role: UserRole.customer,
              ),
              isInitialized: true,
            );
          }
        } else {
          // If no firebase user, we still check mock admin later
          if (!state.isInitialized || state.user == null) {
            state = state.copyWith(user: null, isInitialized: true);
          }
        }
      });
    } catch (e) {
      debugPrint('AuthNotifier: Firebase listener setup failed: $e');
      state = state.copyWith(isFirebaseConfigured: false, isInitialized: true);
    }

    // 3. Load SharedPreferences for mock admin in shadow
    _loadMockAdmin();
  }

  Future<void> _loadMockAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMockAdmin = prefs.getBool('is_mock_admin') ?? false;

      if (isMockAdmin && state.user == null) {
        debugPrint('AuthNotifier: Restoring mock admin session');
        state = state.copyWith(
          user: User(
            id: 'admin_id',
            email: 'admin@gmail.com',
            name: 'Admin',
            role: UserRole.restaurant,
          ),
          isInitialized: true,
        );
      }
    } catch (e) {
      debugPrint('AuthNotifier: Error loading SharedPreferences: $e');
    }
  }

  Future<void> login(String email, String password) async {
    // Hardcoded admin bypass for local testing as requested
    if (email == 'admin@gmail.com' && password == 'admin123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_mock_admin', true);

      state = state.copyWith(
        user: User(
            id: 'admin_id',
            email: email,
            name: 'Admin',
            role: UserRole.restaurant),
        isLoading: false,
        isInitialized: true,
      );
      return;
    }

    if (!state.isFirebaseConfigured) {
      state = state.copyWith(
          error:
              'Firebase is not configured. Please run "flutterfire configure".',
          isInitialized: true);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get()
              .timeout(const Duration(seconds: 10));
            if (doc.exists) {
              final user = User.fromMap(doc.data()!, firebaseUser.uid);
              debugPrint(
                  'AuthNotifier: Login profile success: ${user.email} (Role: ${user.role})');

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_role', user.role.toString());

              state = state.copyWith(
                user: user,
                isInitialized: true,
                isLoading: false,
              );
            } else {
            debugPrint(
                'AuthNotifier: Login profile not found for ${firebaseUser.email}');
            // Document doesn't exist yet but user is authenticated
            state = state.copyWith(
                user: User(
                    id: firebaseUser.uid,
                    email: firebaseUser.email ?? '',
                    name: firebaseUser.displayName ?? 'New User',
                    role: UserRole.customer),
                isInitialized: true,
                isLoading: false);
          }
        } catch (e) {
          debugPrint('AuthNotifier: Login profile fetch error: $e');
          // Firestore error (likely permission or network) - Proceed as customer fallback
          state = state.copyWith(
              isLoading: false,
              user: User(
                  id: firebaseUser.uid,
                  email: firebaseUser.email ?? '',
                  name: firebaseUser.displayName ?? 'Pending Profile',
                  role: UserRole.customer),
              isInitialized: true,
              error:
                  'Success, but profile load failed. Logged in as customer.');
        }
      } else {
        state = state.copyWith(
            isLoading: false,
            error: 'Login failed: No user returned.',
            isInitialized: true);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String roleStr, {
    String? restaurantName,
    String? address,
    String? location,
    String? cuisine,
    String? description,
  }) async {
    if (!state.isFirebaseConfigured) {
      state = state.copyWith(error: 'Firebase is not configured.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        final role =
            roleStr == 'restaurant' ? UserRole.restaurant : UserRole.customer;
        final newUser =
            User(id: firebaseUser.uid, email: email, name: name, role: role);

        // Save User document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', newUser.role.toString());

        // If restaurant, also create Restaurant document
        if (role == UserRole.restaurant) {
          final newRestaurant = Restaurant(
            id: firebaseUser.uid,
            ownerId: firebaseUser.uid,
            name: restaurantName ?? name,
            description: (description != null && description.isNotEmpty)
                ? description
                : 'Traditional fusion',
            address: address ?? location ?? '123 Main St',
            location: location ?? 'Kozhikode City',
            rating: 4.5, // Start with a good rating
            imageUrl:
                'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
            cuisine: (cuisine != null && cuisine.isNotEmpty)
                ? cuisine
                : 'Multi-Cuisine',
            phone: '',
            deliveryCharge: 40.0,
            deliveryTime: 34,
            minOrderValue: 130.0,
            distance: '2.8 km',
          );
          await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(firebaseUser.uid)
              .set(newRestaurant.toMap());
        }

        if (role == UserRole.restaurant) {
          // Invalidate providers to reflect new restaurant/reels data
          ref.invalidate(restaurantsStreamProvider);
          ref.invalidate(reelsStreamProvider);
        }
        state = state.copyWith(
            user: newUser, isInitialized: true, isLoading: false);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_mock_admin');
      await prefs.remove('user_role'); // Clear role on logout
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    state = AuthState(
        isFirebaseConfigured: state.isFirebaseConfigured, isInitialized: true);
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
  }) async {
    final user = state.user;
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = user.copyWith(
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
        addresses: addresses,
        paymentMethods: paymentMethods,
      );

      // Handle Mock Admin updates locally
      if (user.id == 'admin_id') {
        state = state.copyWith(user: updatedUser, isLoading: false);
        return;
      }

      // Handle Real Firebase User updates
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(updatedUser.toMap(), SetOptions(merge: true));

      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      debugPrint('AuthNotifier: Update profile error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> addAddress(Address address) async {
    final user = state.user;
    if (user == null) return;
    final updatedAddresses = [...user.addresses, address];
    if (address.isDefault) {
      // Set others to non-default
      for (var i = 0; i < updatedAddresses.length; i++) {
        if (updatedAddresses[i].id != address.id) {
          updatedAddresses[i] = Address(
            id: updatedAddresses[i].id,
            label: updatedAddresses[i].label,
            fullAddress: updatedAddresses[i].fullAddress,
            landmark: updatedAddresses[i].landmark,
            isDefault: false,
          );
        }
      }
    }
    await updateProfile(addresses: updatedAddresses);
  }

  Future<void> removeAddress(String addressId) async {
    final user = state.user;
    if (user == null) return;
    final updatedAddresses =
        user.addresses.where((a) => a.id != addressId).toList();
    await updateProfile(addresses: updatedAddresses);
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    final user = state.user;
    if (user == null) return;
    final updatedMethods = [...user.paymentMethods, method];
    await updateProfile(paymentMethods: updatedMethods);
  }

  Future<void> removePaymentMethod(String methodId) async {
    final user = state.user;
    if (user == null) return;
    final updatedMethods =
        user.paymentMethods.where((p) => p.id != methodId).toList();
    await updateProfile(paymentMethods: updatedMethods);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
