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

**Required — add your App ID to `ios/Runner/Info.plist`:**

```xml
<key>ZPS_APP_ID</key>
<string>YOUR_APP_ID_HERE</string>
```

The iOS SDK reads the App ID from `Info.plist` at startup. Without this entry the SDK initialises silently without credentials and no events are sent. The `appId` parameter passed to `PageSense.init()` is used by Android; iOS uses the `Info.plist` value.

## Initialization

Call `PageSense.init` once in `main.dart` before `runApp`:

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

> **Android** uses the `appId` argument directly.
> **iOS** reads the App ID from `Info.plist` (`ZPS_APP_ID` key) — see setup above.

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
