import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../auth/screens/splash_screen.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/signup_screen.dart';
import '../vendor/screens/vendor_main_screen.dart';
import '../vendor/screens/add_vegetable_screen.dart';
import '../vendor/screens/order_detail_screen.dart';
import '../customer/screens/customer_main_screen.dart';
import '../customer/screens/vegetable_detail_screen.dart';
import '../customer/screens/cart_screen.dart';
import '../customer/screens/order_confirmation_screen.dart';
import '../customer/screens/order_tracking_screen.dart';
import '../customer/screens/search_screen.dart';

final splashReadyProvider = StateProvider<bool>((ref) => false);

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(currentUserProvider, (_, __) => notifyListeners());
    _ref.listen(splashReadyProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final currentUserAsync = ref.read(currentUserProvider);
      final isSplashReady = ref.read(splashReadyProvider);

      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // 0. Enforce minimum splash screen duration
      if (!isSplashReady) {
        return isSplash ? null : '/splash';
      }

      // 1. Wait for Firebase Auth to initialize
      if (authState.isLoading) {
        return isSplash ? null : '/splash';
      }

      final isLoggedIn = authState.value != null;

      // 2. If not logged in, force to login screen
      if (!isLoggedIn) {
        return isAuthRoute ? null : '/auth/login';
      }

      // 3. If logged in, wait for user data to load from Firestore
      if (currentUserAsync.isLoading || !currentUserAsync.hasValue) {
        return isSplash ? null : '/splash';
      }

      final user = currentUserAsync.value;
      if (user == null) {
        // Logged in to Firebase but no Firestore document found (edge case)
        return isAuthRoute ? null : '/auth/login';
      }

      final isVendorRoute = state.matchedLocation.startsWith('/vendor');
      final isCustomerRoute = state.matchedLocation.startsWith('/customer');

      // 4. Role-based routing
      if (user.role == UserRole.vendor) {
        if (isSplash || isAuthRoute || isCustomerRoute) return '/vendor';
      } else {
        if (isSplash || isAuthRoute || isVendorRoute) return '/customer';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/signup', builder: (_, __) => const SignupScreen()),

      // Vendor routes
      GoRoute(
        path: '/vendor',
        builder: (_, __) => const VendorMainScreen(),
        routes: [
          GoRoute(
            path: 'add-vegetable',
            builder: (_, __) => const AddVegetableScreen(),
          ),
          GoRoute(
            path: 'edit-vegetable/:id',
            builder: (ctx, state) =>
                AddVegetableScreen(vegetableId: state.pathParameters['id']),
          ),
          GoRoute(
            path: 'order/:id',
            builder: (ctx, state) =>
                OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
        ],
      ),

      // Customer routes
      GoRoute(
        path: '/customer',
        builder: (_, __) => const CustomerMainScreen(),
        routes: [
          GoRoute(
            path: 'search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: 'vegetable/:id',
            builder: (ctx, state) =>
                VegetableDetailScreen(vegetableId: state.pathParameters['id']!),
          ),
          GoRoute(path: 'cart', builder: (_, __) => const CartScreen()),
          GoRoute(
            path: 'order-confirmation/:id',
            builder: (ctx, state) => OrderConfirmationScreen(
              orderId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'track-order/:id',
            builder: (ctx, state) =>
                OrderTrackingScreen(orderId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
