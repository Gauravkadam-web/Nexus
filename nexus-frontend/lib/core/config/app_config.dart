import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Default API base URL for Nexus Spring Boot 3.3.4 Backend on Web/Desktop
  static const String defaultApiBaseUrl = 'http://localhost:8080/api/v1/';

  /// Explicit IPv4 API base URL for Android physical device over ADB reverse
  static const String androidApiBaseUrl = 'http://127.0.0.1:8080/api/v1/';

  /// Environment-driven API base URL
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv.endsWith('/') ? fromEnv : '$fromEnv/';
    }
    // On physical Android devices connected via ADB reverse, use explicit IPv4 127.0.0.1
    // to prevent Android DNS from resolving localhost to IPv6 loopback [::1], which refuses connections.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return androidApiBaseUrl;
    }
    return defaultApiBaseUrl;
  }

  static const String appName = 'Nexus Case Management';
  static const String appVersion = 'v3.0';

  /// Environment-driven download URL for Android APK
  static String get androidApkDownloadUrl {
    const fromEnv = String.fromEnvironment('APP_DOWNLOAD_ANDROID_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'https://nexus-weld-two.vercel.app/downloads/nexus-release.apk';
  }

  /// Environment-driven download URL for Windows Client (.exe Setup Installer)
  static String get windowsExeDownloadUrl {
    const fromEnv = String.fromEnvironment('APP_DOWNLOAD_WINDOWS_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'https://github.com/Gauravkadam-web/Nexus-/releases/download/v1.0.0/nexus-windows-setup.exe';
  }
}

