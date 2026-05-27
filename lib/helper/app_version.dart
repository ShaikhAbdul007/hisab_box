import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Singleton — call AppVersion.load() once at app start (in SplashController).
/// Then read AppVersion.version / AppVersion.buildNumber anywhere.
class AppVersion {
  AppVersion._();

  static final RxString version = '1.0.0'.obs;
  static final RxString buildNumber = '1'.obs;

  static Future<void> load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      version.value = info.version;
      buildNumber.value = info.buildNumber;
    } catch (_) {
      // keep defaults
    }
  }

  /// e.g. "v1.2.3 (45)"
  static String get display => 'v${version.value} (${buildNumber.value})';
}
