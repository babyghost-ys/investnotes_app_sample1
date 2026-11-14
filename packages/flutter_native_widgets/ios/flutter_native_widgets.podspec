#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_native_widgets.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_native_widgets'
  s.version          = '0.1.0'
  s.summary          = 'Native widgets for Flutter with iOS 26 native support.'
  s.description      = <<-DESC
A Flutter package that provides native platform-specific widgets with native iOS 26+ designs,
traditional Cupertino widgets for older iOS versions, and Material Design for Android.
                       DESC
  s.homepage         = 'https://github.com/berkaycatak/adaptive_platform_ui'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Berkay Catak' => 'berkaycatak@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_native_widgets/Sources/flutter_native_widgets/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
