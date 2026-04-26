import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoho_pagesense/src/models/config.dart';
import 'package:zoho_pagesense/src/platform/method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('zoho_pagesense');
  final platform = PageSenseMethodChannel();

  final List<MethodCall> log = [];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          log.add(call);
          return null;
        });
  });

  tearDown(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('init sends correct arguments', () async {
    await platform.init('my-app-id', PageSenseDataCenter.sa);

    expect(log, hasLength(1));
    expect(log.first.method, 'init');
    expect(log.first.arguments['appId'], 'my-app-id');
    expect(log.first.arguments['dataCenter'], 'SA');
  });

  test('setUserId sends userId', () async {
    await platform.setUserId('user_42');

    expect(log.first.method, 'setUserId');
    expect(log.first.arguments['userId'], 'user_42');
  });

  test('setUserId with null sends null', () async {
    await platform.setUserId(null);

    expect(log.first.arguments['userId'], isNull);
  });
}
