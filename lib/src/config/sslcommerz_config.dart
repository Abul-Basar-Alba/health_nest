// lib/src/config/sslcommerz_config.dart

class SSLCommerzConfig {
  // Sandbox Configuration (তোমার real credentials)
  static const String storeId = 'ab68f66c73a5bf5';
  static const String storePassword = 'ab68f66c73a5bf5@ssl';
  static const String sandboxUrl = 'https://sandbox.sslcommerz.com';
  static const String sessionAPI =
      'https://sandbox.sslcommerz.com/gwprocess/v3/api.php';
  static const String validationAPI =
      'https://sandbox.sslcommerz.com/validator/api/validationserverAPI.php';

  // Return URLs
  static const String successUrl = 'https://healthnest.com/payment/success';
  static const String failUrl = 'https://healthnest.com/payment/fail';
  static const String cancelUrl = 'https://healthnest.com/payment/cancel';

  // Currency
  static const String currency = 'BDT';
}
