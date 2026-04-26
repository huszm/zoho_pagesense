/// Zoho data center region.
///
/// Determines which Zoho server cluster receives analytics events.
/// Defaults to [sa] (Saudi Arabia) when not specified.
enum PageSenseDataCenter {
  us('US'),
  eu('EU'),
  // ignore: constant_identifier_names
  in_('IN'),
  au('AU'),
  sa('SA');

  const PageSenseDataCenter(this.value);

  /// The string identifier sent to the native SDK.
  final String value;
}
