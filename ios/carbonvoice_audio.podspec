#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint carbonvoice_audio.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'carbonvoice_audio'
  s.version          = '1.0.5'
  s.summary          = 'Flutter audio plugin'
  s.description      = 'Flutter audio plugin interface'
  s.homepage         = 'https://github.com/PhononX/carbonvoice_audio'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'PhononX' => 'manuel@phononx.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'CarbonVoiceAudio', '~> 1.0.3'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
