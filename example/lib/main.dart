import 'package:flutter/material.dart';
import 'package:zoho_pagesense/zoho_pagesense.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace with your real App ID (or fetch it from your server first).
  final result = await PageSense.init(appId: 'YOUR_APP_ID_HERE');
  debugPrint('PageSense init: $result');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PageSense Example',
      // Automatically tracks every named-route push.
      navigatorObservers: [PageSenseRouteObserver()],
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/detail': (_) => const DetailPage(),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Home — demonstrates all available SDK calls
// ---------------------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _lastResult = '—';

  void _show(PageSenseResult r) => setState(() => _lastResult =
      r.isSuccess ? 'Success' : (r as PageSenseFailure).toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PageSense Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Result banner
          Card(
            color: _lastResult == '—'
                ? null
                : _lastResult == 'Success'
                    ? Colors.green.shade50
                    : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                const Text('Last result: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(_lastResult)),
              ]),
            ),
          ),

          _section(context, 'User identity'),
          _btn('Set user ID', () async =>
              _show(await PageSense.instance.setUserId('demo@example.com'))),
          _btn('Clear user ID', () async =>
              _show(await PageSense.instance.setUserId(null))),

          _section(context, 'Events'),
          _btn('Track simple event', () async =>
              _show(await PageSense.instance.trackEvent('button_tapped'))),
          _btn('Track event with properties', () async => _show(
            await PageSense.instance.trackEvent('add_to_cart', {
              'product_id': 'SKU-123',
              'price': 49.99,
              'quantity': 2,
            }),
          )),

          _section(context, 'Screen tracking'),
          _btn('Track screen manually', () async =>
              _show(await PageSense.instance.trackScreen('HomePage'))),
          _btn('Track screen with properties', () async => _show(
            await PageSense.instance.trackScreen('ProductDetail', {
              'product_id': 'SKU-123',
            }),
          )),
          _btn('Navigate to detail (auto-tracked)',
              () => Navigator.pushNamed(context, '/detail')),

          _section(context, 'Purchase'),
          _btn('Track purchase', () async => _show(
            await PageSense.instance.trackPurchase(
              amount: 99.99,
              currency: 'USD',
              productId: 'SKU-123',
            ),
          )),

          _section(context, 'Push notifications'),
          _btn('Register push token (demo)', () async => _show(
            // In a real app pass the FCM token from FirebaseMessaging.getToken()
            // or the APNs token from FirebaseMessaging.getAPNSToken() on iOS.
            await PageSense.instance.setPushToken('demo_token_replace_me'),
          )),

          _section(context, 'Privacy'),
          _btn('Disable tracking', () async =>
              _show(await PageSense.instance.setTrackingEnabled(false))),
          _btn('Enable tracking', () async =>
              _show(await PageSense.instance.setTrackingEnabled(true))),
          _btn('Clear all data', () async =>
              _show(await PageSense.instance.clearAllData())),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 4),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey.shade600)),
      );

  Widget _btn(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: onTap, child: Text(label)),
        ),
      );
}

// ---------------------------------------------------------------------------
// Detail — auto-tracked by PageSenseRouteObserver when pushed via named route
// ---------------------------------------------------------------------------

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: const Center(
        child: Text('Screen view for "/detail" was auto-tracked.'),
      ),
    );
  }
}
