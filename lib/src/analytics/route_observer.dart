import 'package:flutter/widgets.dart';

import '../pagesense.dart';

/// A [NavigatorObserver] that automatically calls [PageSense.trackScreen]
/// on every route push.
///
/// Add to [MaterialApp.navigatorObservers]:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [PageSenseRouteObserver()],
/// )
/// ```
class PageSenseRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _trackRoute(newRoute);
  }

  void _trackRoute(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    if (!PageSense.isInitialized) return;
    PageSense.instance.trackScreen(name);
  }
}
