import 'models/result.dart';
import 'platform/method_channel.dart';
import 'platform/platform_interface.dart';

export 'models/result.dart';
export 'analytics/route_observer.dart';

/// Primary entry point for Zoho PageSense Mobile Analytics.
///
/// Call [PageSense.init] once in [main] before using any other method:
/// ```dart
/// final result = await PageSense.init(appId: 'your-app-id');
/// if (!result.isSuccess) { /* handle */ }
/// ```
class PageSense {
  PageSense._();

  static PageSense? _instance;

  /// Whether [init] has been called successfully.
  static bool get isInitialized => _instance != null;

  /// The singleton after [init] has succeeded.
  static PageSense get instance {
    assert(
      _instance != null,
      'PageSense.init() must be called before accessing PageSense.instance.',
    );
    return _instance!;
  }

  /// Initialises the SDK and the underlying native PageSense library.
  ///
  /// Returns [PageSenseSuccess] on success. On failure the singleton is NOT
  /// set, so [isInitialized] remains `false`.
  static Future<PageSenseResult> init({
    required String appId,
  }) async {
    PageSensePlatform.instance = PageSenseMethodChannel();
    final result = await PageSensePlatform.instance.init(appId);
    if (result.isSuccess) _instance = PageSense._();
    return result;
  }

  /// Associates all subsequent events with [userId].
  ///
  /// Pass `null` to revert to anonymous tracking.
  Future<PageSenseResult> setUserId(String? userId) {
    return PageSensePlatform.instance.setUserId(userId);
  }

  /// Tracks a screen view with an optional property map.
  Future<PageSenseResult> trackScreen(
    String name, [
    Map<String, Object>? properties,
  ]) {
    return PageSensePlatform.instance.trackScreen(name, properties);
  }

  /// Tracks a named custom event with optional properties.
  Future<PageSenseResult> trackEvent(
    String name, [
    Map<String, Object>? properties,
  ]) {
    return PageSensePlatform.instance.trackEvent(name, properties);
  }

  /// Convenience wrapper for purchase events.
  Future<PageSenseResult> trackPurchase({
    required double amount,
    required String currency,
    String? productId,
  }) {
    return PageSensePlatform.instance.trackPurchase(amount, currency, productId);
  }

  /// Enables or disables all analytics collection.
  Future<PageSenseResult> setTrackingEnabled(bool enabled) {
    return PageSensePlatform.instance.setTrackingEnabled(enabled);
  }

  /// Wipes all locally stored analytics data (GDPR right-to-erasure).
  Future<PageSenseResult> clearAllData() {
    return PageSensePlatform.instance.clearAllData();
  }
}
