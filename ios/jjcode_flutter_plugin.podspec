#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint jjcode_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'jjcode_flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'jijiancode flutter plugin'
  s.description      = <<-DESC
jijiancode  flutter plugin
                       DESC
  s.homepage         = 'https://www.jijiancode.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { '极简验证' => 'jijian@shoot.net.cn' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'
  s.dependency 'JijiancodeSDK', "~> 1.2.0"

  s.platform = :ios, '9.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
