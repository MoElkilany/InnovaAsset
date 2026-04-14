import 'dart:io';

/// Central configuration for the Innova app.
/// Selection is automatic based on the platform.
class AppConstants {
  AppConstants._();

  // ─── App Identity ─────────────────────────────────────────────────────────
  static const String appName = 'Innova';
  static const String appVersion = '1.0.0';
  static const String bundleId = 'com.innova.app';

  // ─── WebView Config ────────────────────────────────────────────────────────
  static const String androidBaseUrl = 'https://assetfront-001-site1.rtempurl.com/login';
  static const String iosBaseUrl = 'https://assetfront-001-site1.rtempurl.com/login';

  /// Selects the correct URL based on the current platform.
  static String get baseUrl => Platform.isIOS ? iosBaseUrl : androidBaseUrl;

  /// Allowed hosts — navigation outside this list opens in external browser.
  static const List<String> allowedHosts = [
    '62.149.83.161',
    'assetinnova-001-site1.qtempurl.com',
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

  // ─── Hive Storage Box Names ────────────────────────────────────────────────
  static const String assetsBox = 'assets_box';
  static const String categoriesBox = 'categories_box';
  static const String locationsBox = 'locations_box';
  static const String descriptionsBox = 'descriptions_box';
}
