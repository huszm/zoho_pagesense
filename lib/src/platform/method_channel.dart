import 'package:flutter/services.dart';

import '../models/config.dart';
import 'platform_interface.dart';

class PageSenseMethodChannel extends PageSensePlatform {
  static const MethodChannel _channel = MethodChannel('zoho_pagesense');

  @override
  Future<void> init(String appId, PageSenseDataCenter dataCenter) async {
    await _channel.invokeMethod<void>('init', {
      'appId': appId,
      'dataCenter': dataCenter.value,
    });
  }

  @override
  Future<void> setUserId(String? userId) async {
    await _channel.invokeMethod<void>('setUserId', {'userId': userId});
  }

  @override
  Future<void> trackScreen(String name, Map<String, Object>? properties) async {
    await _channel.invokeMethod<void>('trackScreen', {
      'name': name,
      if (properties != null) 'properties': properties,
    });
  }

  @override
  Future<void> trackEvent(String name, Map<String, Object>? properties) async {
    await _channel.invokeMethod<void>('trackEvent', {
      'name': name,
      if (properties != null) 'properties': properties,
    });
  }

  @override
  Future<void> trackPurchase(
    double amount,
    String currency,
    String? productId,
  ) async {
    await _channel.invokeMethod<void>('trackPurchase', {
      'amount': amount,
      'currency': currency,
      if (productId != null) 'productId': productId,
    });
  }

  @override
  Future<void> setTrackingEnabled(bool enabled) async {
    await _channel.invokeMethod<void>('setTrackingEnabled', {
      'enabled': enabled,
    });
  }

  @override
  Future<void> clearAllData() async {
    await _channel.invokeMethod<void>('clearAllData');
  }
}
