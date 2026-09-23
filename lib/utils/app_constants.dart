/// Central place for all magic strings and configuration constants.
/// Import this anywhere instead of scattering raw strings throughout the app.
class AppConstants {
  AppConstants._();

  // ── Firestore Collections ──────────────────────────────────────────────────
  static const String colUsers       = 'users';
  static const String colVegetables  = 'vegetables';
  static const String colOrders      = 'orders';

  // ── Firebase Storage Paths ────────────────────────────────────────────────
  static const String storageVegetables = 'vegetables';
  static const String storageUsers      = 'users';

  // ── FCM ───────────────────────────────────────────────────────────────────
  static const String fcmChannelId   = 'freshveg_orders';
  static const String fcmChannelName = 'Order Updates';

  // ── Offline Cache ─────────────────────────────────────────────────────────
  static const String cacheKeyVegetables   = 'cached_vegetables';
  static const String cacheKeyTimestamp    = 'vegetables_cache_timestamp';
  static const int    cacheDurationHours   = 6;

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int ordersPageSize      = 20;
  static const int vegetablesPageSize  = 50;

  // ── Validation ────────────────────────────────────────────────────────────
  static const int    passwordMinLength = 6;
  static const int    phoneMinLength    = 10;
  static const double maxImageSizeMb    = 5.0;
  static const int    maxImageWidth     = 800;
  static const int    imageQuality      = 75;

  // ── Order Quantity ────────────────────────────────────────────────────────
  static const double minOrderQty  = 0.5;
  static const double qtyStep      = 0.5;

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName    = 'FreshVeg';
  static const String appTagline = 'Fresh from farm to your table';
  static const String supportEmail = 'support@freshveg.app';

  // ── Route Paths ───────────────────────────────────────────────────────────
  static const String routeSplash             = '/splash';
  static const String routeLogin              = '/auth/login';
  static const String routeSignup             = '/auth/signup';
  static const String routeVendor             = '/vendor';
  static const String routeVendorAddVeg       = '/vendor/add-vegetable';
  static const String routeCustomer           = '/customer';
  static const String routeCustomerCart       = '/customer/cart';
  static const String routeCustomerSearch     = '/customer/search';
}
