Pod::Spec.new do |s|
  s.name             = 'zoho_pagesense'
  s.version          = '0.1.0'
  s.summary          = 'Unofficial Flutter SDK for Zoho PageSense Mobile Analytics.'
  s.description      = <<-DESC
Flutter plugin that wraps the native Zoho PageSense Mobile Analytics SDK.
Supports sessions, installs, custom events, screen tracking, and retention.
                       DESC
  s.homepage         = 'https://github.com/appsbunches/zoho_pagesense'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Apps Bunches' => 'Ai@appsbunches.net' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'PageSenseSDK'
  s.platform         = :ios, '13.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
