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

The plugin depends on `ZohoPageSenseSDK` via CocoaPods. After `flutter pub get`, run:

```sh
cd ios && pod install
```

Minimum deployment target: **iOS 13.0**.

## Initialization

Call `PageSense.init` once in `main.dart` before `runApp`, passing the App ID from your Zoho PageSense dashboard:

```dart
import 'package:zoho_pagesense/zoho_pagesense.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PageSense.init(appId: 'YOUR_APP_ID');

  runApp(const MyApp());
}
```

### Data center

The default data center is Saudi Arabia (`SA`). Pass `dataCenter` to target a different region:

```dart
await PageSense.init(
  appId: 'YOUR_APP_ID',
  dataCenter: PageSenseDataCenter.us, // us, eu, in_, au, sa
);
```

### User identity

Associate events with a known user after login, and clear the identity on logout:

```dart
// After login
PageSense.instance.setUserId('user@example.com');

// After logout
PageSense.instance.setUserId(null);
```

### Automatic screen tracking

Add `PageSenseRouteObserver` to your `MaterialApp` to track every screen push automatically:

```dart
MaterialApp(
  navigatorObservers: [PageSenseRouteObserver()],
  // ...
)
```
