Pod::Spec.new do |s|
  s.name             = "KantarMediaWaterDetection"
  s.version          = '1.0.0'
  s.summary          = "KantarMediaWaterDetection"
  s.description      = <<-DESC
                        plugin that provides Kantar Media's API to process whatermarking detection.
                       DESC
  s.homepage         = "https://github.com/applicaster/KantarMediaWaterDetection"
  s.license          = 'CMPS'
  s.author           = { "cmps" => "r.kedarya@applicaster.com" }
  s.source           = { :git => "git@github.com:applicaster/KantarMediaWaterDetection.git", :tag => s.version.to_s }
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  
  s.vendored_frameworks = 'Frameworks/SyncNowDetectoriOS.framework'
  s.public_header_files = 'KantarMediaWaterDetection/**/*.h'
  s.source_files = 'KantarMediaWaterDetection/**/*.{h,m,swift}'


  s.resources = [
    "**/*.{png,xib}"
  ]

  s.xcconfig =  {
                  'ENABLE_BITCODE' => 'YES',
                  'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}"/**',
                  'SWIFT_VERSION' => '4.2'
                }

  s.dependency 'ZappPlugins'
end
