/// Central configuration for the Innova app.
class AppConstants {
  AppConstants._();

  // ─── App Identity ─────────────────────────────────────────────────────────
  static const String appName = 'Innova';
  static const String appVersion = '1.0.0';
  static const String bundleId = 'com.innova.app';

  // ─── WebView Config ────────────────────────────────────────────────────────
  /// Single base URL used on every platform (Android, iOS, etc.).
  static const String baseUrl = 'https://asset.innovandmore.com/';

  /// Allowed hosts — navigation outside this list opens in external browser.
  static const List<String> allowedHosts = [
    'asset.innovandmore.com',
    'www.asset.innovandmore.com',
  ];

  // ─── URL Schemes that must be launched externally ─────────────────────────
  static const List<String> externalSchemes = [
    'tel',
    'mailto',
    'whatsapp',
    'sms',
    'maps',
    'geo',
  ];

  // ─── Timeouts ─────────────────────────────────────────────────────────────
  static const Duration connectivityCheckInterval = Duration(seconds: 5);
}
