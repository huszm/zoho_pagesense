import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:zoho_pagesense/zoho_pagesense.dart';

import 'package:zoho_pagesense/src/platform/platform_interface.dart';

class _MockPageSensePlatform
    with MockPlatformInterfaceMixin
    implements PageSensePlatform {
  String? lastAppId;

  @override
  Future<PageSenseResult> init(String appId) async {
    lastAppId = appId;
    return const PageSenseSuccess();
  }

  @override
  Future<PageSenseResult> setUserId(String? userId) async => const PageSenseSuccess();

  @override
  Future<PageSenseResult> trackScreen(
    String name,
    Map<String, Object>? properties,
  ) async => const PageSenseSuccess();

  @override
  Future<PageSenseResult> trackEvent(String name, Map<String, Object>? properties) async => const PageSenseSuccess();

  @override
  Future<PageSenseResult> trackPurchase(
    double amount,
    String currency,
    String? productId,
  ) async => const PageSenseSuccess();

  @override
  Future<PageSenseResult> setTrackingEnabled(bool enabled) async => const PageSenseSuccess();

  @override
  Future<PageSenseResult> clearAllData() async => const PageSenseSuccess();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PageSense.init', () {
    late _MockPageSensePlatform mock;

    setUp(() {
      mock = _MockPageSensePlatform();
      PageSensePlatform.instance = mock;
    });

    test('passes appId to platform', () async {
      const channel = MethodChannel('zoho_pagesense');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      PageSensePlatform.instance = mock;
      await PageSensePlatform.instance.init(
        'test-app-id',
      );

      expect(mock.lastAppId, 'test-app-id');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  });
}
