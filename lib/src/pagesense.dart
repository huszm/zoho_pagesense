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
  void trackScreen(String name, [Map<String, Object>? properties]) {
    throw UnimplementedError('trackScreen is implemented in Phase 3.');
  }

  /// Tracks a named custom event with optional properties.
  void trackEvent(String name, [Map<String, Object>? properties]) {
    throw UnimplementedError('trackEvent is implemented in Phase 3.');
  }

  /// Convenience wrapper for purchase events.
  void trackPurchase({
    required double amount,
    required String currency,
    String? productId,
  }) {
    throw UnimplementedError('trackPurchase is implemented in Phase 3.');
  }

  /// Enables or disables all analytics collection.
  ///
  /// When [enabled] is `false` the queue is dropped and no new events
  /// are sent until re-enabled.
  void setTrackingEnabled(bool enabled) {
    throw UnimplementedError('setTrackingEnabled is implemented in Phase 5.');
  }

  /// Wipes all locally stored analytics data (GDPR right-to-erasure).
  void clearAllData() {
    throw UnimplementedError('clearAllData is implemented in Phase 5.');
  }
}
