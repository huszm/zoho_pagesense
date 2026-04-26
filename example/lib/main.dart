import 'package:flutter/material.dart';
import 'package:zoho_pagesense/zoho_pagesense.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PageSense.init(
    appId: 'YOUR_APP_ID_HERE',
    dataCenter: PageSenseDataCenter.sa,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PageSense Example',
      navigatorObservers: [PageSenseRouteObserver()],
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PageSense Demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SDK initialised ✓'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                PageSense.instance.setUserId('demo_user_1');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('User ID set')));
              },
              child: const Text('Set User ID'),
            ),
          ],
        ),
      ),
    );
  }
}
