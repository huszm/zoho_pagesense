import 'package:flutter/services.dart';

import '../models/config.dart';
import '../models/result.dart';
import 'platform_interface.dart';

class PageSenseMethodChannel extends PageSensePlatform {
  static const MethodChannel _channel = MethodChannel('zoho_pagesense');

  /// Invokes [method] with optional [args] and converts the outcome to a
  /// [PageSenseResult]. A [PlatformException] from the native side becomes a
  /// [PageSenseFailure]; any other exception is re-thrown unchanged.
  Future<PageSenseResult> _invoke(
    String method, [
    Map<String, Object?>? args,
  ]) async {
    try {
      await _channel.invokeMethod<void>(method, args);
      return const PageSenseSuccess();
    } on PlatformException catch (e) {
      return PageSenseFailure(code: e.code, message: e.message);
    }
  }

  @override
  Future<PageSenseResult> init(String appId, PageSenseDataCenter dataCenter) {
    return _invoke('init', {'appId': appId, 'dataCenter': dataCenter.value});
  }

  @override
  Future<PageSenseResult> setUserId(String? userId) {
    return _invoke('setUserId', {'userId': userId});
  }

  @override
  Future<PageSenseResult> trackScreen(
    String name,
    Map<String, Object>? properties,
  ) {
    return _invoke('trackScreen', {
      'name': name,
      if (properties != null) 'properties': properties,
    });
  }

  @override
  Future<PageSenseResult> trackEvent(
    String name,
    Map<String, Object>? properties,
  ) {
    return _invoke('trackEvent', {
      'name': name,
      if (properties != null) 'properties': properties,
    });
  }

  @override
  Future<PageSenseResult> trackPurchase(
    double amount,
    String currency,
    String? productId,
  ) {
    return _invoke('trackPurchase', {
      'amount': amount,
      'currency': currency,
      if (productId != null) 'productId': productId,
    });
  }

  @override
  Future<PageSenseResult> setTrackingEnabled(bool enabled) {
    return _invoke('setTrackingEnabled', {'enabled': enabled});
  }

  @override
  Future<PageSenseResult> clearAllData() {
    return _invoke('clearAllData');
  }
}
