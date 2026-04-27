/// The result of every PageSense SDK call.
///
/// Use exhaustive pattern matching to handle both outcomes:
/// ```dart
/// switch (await PageSense.instance.trackEvent('add_to_cart')) {
///   case PageSenseSuccess():
///     print('tracked');
///   case PageSenseFailure(:final code, :final message):
///     print('failed $code: $message');
/// }
/// ```
///
/// For fire-and-forget callers, use [isSuccess]:
/// ```dart
/// final ok = (await PageSense.instance.trackEvent('view')).isSuccess;
/// ```
sealed class PageSenseResult {
  const PageSenseResult();

  bool get isSuccess => this is PageSenseSuccess;
}

/// The call completed without error.
final class PageSenseSuccess extends PageSenseResult {
  const PageSenseSuccess();
}

/// The call failed. [code] is the native error code; [message] is optional detail.
final class PageSenseFailure extends PageSenseResult {
  final String code;
  final String? message;

  const PageSenseFailure({required this.code, this.message});

  @override
  String toString() => 'PageSenseFailure($code: $message)';
}
