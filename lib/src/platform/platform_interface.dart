import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../models/config.dart';

abstract class PageSensePlatform extends PlatformInterface {
  PageSensePlatform() : super(token: _token);

  static final Object _token = Object();

  static PageSensePlatform? _instance;

  static PageSensePlatform get instance {
    assert(_instance != null, 'PageSense.init() has not been called.');
    return _instance!;
  }

  static set instance(PageSensePlatform value) {
    PlatformInterface.verifyToken(value, _token);
    _instance = value;
  }

  Future<void> init(String appId, PageSenseDataCenter dataCenter);

  Future<void> setUserId(String? userId);

  Future<void> trackScreen(String name, Map<String, Object>? properties);

  Future<void> trackEvent(String name, Map<String, Object>? properties);

  Future<void> trackPurchase(double amount, String currency, String? productId);

  Future<void> setTrackingEnabled(bool enabled);

  Future<void> clearAllData();
}
