# zoho_pagesense

Unofficial Flutter plugin for [Zoho PageSense Mobile Analytics](https://www.zoho.com/pagesense/). Tracks sessions, installs, screen views, custom events, and user identity on Android and iOS.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  zoho_pagesense:
    git:
      url: https://github.com/appsbunches/zoho_pagesense.git
      ref: main
```

Then run:

```sh
flutter pub get
```

### Android

No additional setup required.

### iOS

The plugin depends on `PageSenseSDK` via CocoaPods. After `flutter pub get`, run:

```sh
cd ios && pod install
```

Minimum deployment target: **iOS 13.0**.

No `Info.plist` entry is required. The plugin injects the App ID at runtime, so it can be passed directly to `PageSense.init()` — including values fetched dynamically from your own server.

## Usage

### Initialization

Call `PageSense.init` once, before tracking any events. The App ID can be hardcoded or fetched from a remote source.

```dart
import 'package:zoho_pagesense/zoho_pagesense.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final result = await PageSense.init(appId: 'YOUR_APP_ID');
  if (!result.isSuccess) {
    // handle initialisation failure
  }

  runApp(const MyApp());
}
```

**Dynamic App ID** — if you fetch the ID from your backend, call `PageSense.init` whenever the ID becomes available. Events tracked before init are silently ignored.

```dart
final appId = await myApi.fetchPageSenseAppId();
await PageSense.init(appId: appId);
```

### Return values

Every method returns a `PageSenseResult`. Use `.isSuccess` for fire-and-forget calls, or exhaustive pattern matching when you need the error detail:

```dart
// fire-and-forget
await PageSense.instance.trackEvent('add_to_cart');

// handle failure
final result = await PageSense.instance.trackEvent('checkout');
switch (result) {
  case PageSenseSuccess():
    print('tracked');
  case PageSenseFailure(:final code, :final message):
    print('error $code: $message');
}
```

### User identity

Associate all subsequent events with a known user after login, and clear the identity on logout:

```dart
// After login
await PageSense.instance.setUserId('user@example.com');

// After logout
await PageSense.instance.setUserId(null);
```

### Track events

```dart
// Simple event
await PageSense.instance.trackEvent('button_tapped');

// Event with properties
await PageSense.instance.trackEvent('add_to_cart', {
  'product_id': 'SKU-123',
  'price': 49.99,
  'quantity': 2,
});
```

### Track screen views

```dart
// Manual screen tracking
await PageSense.instance.trackScreen('ProductDetail');

// With extra properties
await PageSense.instance.trackScreen('ProductDetail', {
  'product_id': 'SKU-123',
});
```

**Automatic screen tracking** — add `PageSenseRouteObserver` to your `MaterialApp` to track every named route push automatically:

```dart
MaterialApp(
  navigatorObservers: [PageSenseRouteObserver()],
  routes: {
    '/home':    (_) => const HomePage(),
    '/product': (_) => const ProductPage(),
  },
)
```

### Track purchases

```dart
await PageSense.instance.trackPurchase(
  amount: 99.99,
  currency: 'USD',
  productId: 'SKU-123', // optional
);
```

### Privacy controls

```dart
// Disable all tracking (e.g. user opted out)
await PageSense.instance.setTrackingEnabled(false);

// Re-enable
await PageSense.instance.setTrackingEnabled(true);

// Wipe all locally stored analytics data (GDPR right-to-erasure)
await PageSense.instance.clearAllData();
```

## API reference

| Method | Description |
|---|---|
| `PageSense.init(appId:)` | Initialises the SDK. Must be called before any other method. |
| `instance.setUserId(String?)` | Associates events with a user. Pass `null` to clear. |
| `instance.trackEvent(name, [properties])` | Tracks a named custom event with optional `Map<String, dynamic>` properties. |
| `instance.trackScreen(name, [properties])` | Tracks a screen view. |
| `instance.trackPurchase(amount:currency:productId:)` | Convenience wrapper for purchase events. |
| `instance.setTrackingEnabled(bool)` | Enables or disables analytics collection. |
| `instance.clearAllData()` | Wipes all locally stored analytics data. |
| `PageSense.isInitialized` | `true` after a successful `init` call. |
