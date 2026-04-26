import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:zoho_pagesense/zoho_pagesense.dart';

import 'package:zoho_pagesense/src/platform/platform_interface.dart';
import 'package:zoho_pagesense/src/models/config.dart';

class _MockPageSensePlatform
    with MockPlatformInterfaceMixin
    implements PageSensePlatform {
  String? lastAppId;
  PageSenseDataCenter? lastDataCenter;

  @override
  Future<void> init(String appId, PageSenseDataCenter dataCenter) async {
    lastAppId = appId;
    lastDataCenter = dataCenter;
  }

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> trackScreen(
    String name,
    Map<String, Object>? properties,
  ) async {}

  @override
  Future<void> trackEvent(String name, Map<String, Object>? properties) async {}

  @override
  Future<void> trackPurchase(
    double amount,
    String currency,
    String? productId,
  ) async {}

  @override
  Future<void> setTrackingEnabled(bool enabled) async {}

  @override
  Future<void> clearAllData() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PageSense.init', () {
    late _MockPageSensePlatform mock;

    setUp(() {
      mock = _MockPageSensePlatform();
      PageSensePlatform.instance = mock;
    });

    test('passes appId and dataCenter to platform', () async {
      const channel = MethodChannel('zoho_pagesense');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      PageSensePlatform.instance = mock;
      await PageSensePlatform.instance.init(
        'test-app-id',
        PageSenseDataCenter.sa,
      );

      expect(mock.lastAppId, 'test-app-id');
      expect(mock.lastDataCenter, PageSenseDataCenter.sa);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('default dataCenter is sa', () {
      expect(PageSenseDataCenter.sa.value, 'SA');
    });

    test('all dataCenter values map correctly', () {
      expect(PageSenseDataCenter.us.value, 'US');
      expect(PageSenseDataCenter.eu.value, 'EU');
      // ignore: constant_identifier_names
      expect(PageSenseDataCenter.in_.value, 'IN');
      expect(PageSenseDataCenter.au.value, 'AU');
      expect(PageSenseDataCenter.sa.value, 'SA');
    });
  });
}
