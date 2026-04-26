## 0.1.0

### Added
- Flutter plugin skeleton for Zoho PageSense Mobile Analytics.
- `PageSense.init(appId:, dataCenter:)` — initialises the native SDK on Android and iOS.
- `PageSenseDataCenter` enum with `us`, `eu`, `in_`, `au`, `sa` (default: `sa`).
- `PageSense.instance.setUserId(String?)` — associates events with a user identity.
- `PageSenseRouteObserver` — drop-in `NavigatorObserver` for automatic screen tracking (active in Phase 3).
- Stubs for `trackEvent`, `trackScreen`, `trackPurchase`, `setTrackingEnabled`, `clearAllData`.
- Android: wraps `com.zoho.pagesense:pagesense:1.1.2` via `maven.zohodl.com`.
- iOS: wraps `PageSenseSDK` CocoaPod.
