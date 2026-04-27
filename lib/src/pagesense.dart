import 'models/config.dart';
import 'platform/method_channel.dart';
import 'platform/platform_interface.dart';

export 'models/config.dart';
export 'analytics/route_observer.dart';

/// Primary entry point for Zoho PageSense Mobile Analytics.
///
/// Call [PageSense.init] once in [main] before using any other method:
/// ```dart
/// await PageSense.init(appId: 'your-app-id');
/// ```
class PageSense {
  PageSense._();

  static PageSense? _instance;

  /// Whether [init] has been called.
  static bool get isInitialized => _instance != null;

  /// The singleton after [init] has been called.
  static PageSense get instance {
    assert(
      _instance != null,
      'PageSense.init() must be called before accessing PageSense.instance.',
    );
    return _instance!;
  }

  /// Initialises the SDK and the underlying native PageSense library.
  ///
  /// [appId] is the App ID shown in the Zoho PageSense dashboard.
  /// [dataCenter] defaults to [PageSenseDataCenter.sa].
  static Future<void> init({
    required String appId,
    PageSenseDataCenter dataCenter = PageSenseDataCenter.sa,
  }) async {
    PageSensePlatform.instance = PageSenseMethodChannel();
    await PageSensePlatform.instance.init(appId, dataCenter);
    _instance = PageSense._();
  }

  /// Associates all subsequent events with [userId].
  ///
  /// Pass `null` to revert to anonymous tracking.
  void setUserId(String? userId) {
    PageSensePlatform.instance.setUserId(userId);
  }

  /// Tracks a screen view with an optional property map.
  Future<void> trackScreen(String name, [Map<String, Object>? properties]) {
    return PageSensePlatform.instance.trackScreen(name, properties);
  }

  /// Tracks a named custom event with optional properties.
  Future<void> trackEvent(String name, [Map<String, Object>? properties]) {
    return PageSensePlatform.instance.trackEvent(name, properties);
  }

  /// Convenience wrapper for purchase events.
  Future<void> trackPurchase({
    required double amount,
    required String currency,
    String? productId,
  }) {
    return PageSensePlatform.instance.trackPurchase(amount, currency, productId);
  }

  /// Enables or disables all analytics collection.
  Future<void> setTrackingEnabled(bool enabled) {
    return PageSensePlatform.instance.setTrackingEnabled(enabled);
  }

  /// Wipes all locally stored analytics data (GDPR right-to-erasure).
  Future<void> clearAllData() {
    return PageSensePlatform.instance.clearAllData();
  }
}
