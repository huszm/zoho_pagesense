import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../models/config.dart';
import '../models/result.dart';

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

  Future<PageSenseResult> init(String appId, PageSenseDataCenter dataCenter);

  Future<PageSenseResult> setUserId(String? userId);

  Future<PageSenseResult> trackScreen(String name, Map<String, Object>? properties);

  Future<PageSenseResult> trackEvent(String name, Map<String, Object>? properties);

  Future<PageSenseResult> trackPurchase(double amount, String currency, String? productId);

  Future<PageSenseResult> setTrackingEnabled(bool enabled);

  Future<PageSenseResult> clearAllData();
}
