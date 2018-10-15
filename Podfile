source "https://github.com/CocoaPods/Specs.git"
source "https://github.com/TouchInstinct/Podspecs.git"

abstract_target 'LeadKitAdditions' do
  pod "KeychainAccess", '3.1.0'
  pod "CryptoSwift", "~> 0.9.0"
  pod "SwiftValidator", '5.0.0'
  pod "SwiftLint", '~> 0.25'
  pod "PinLayout", '~> 1.6'

  inhibit_all_warnings!
  use_frameworks!

  target 'LeadKitAdditions iOS' do
    platform :ios, '9.0'

    pod 'LeadKit', :path => '~/Projects/LeadKit/'
    # pod 'LeadKit', '~> 0.8.0'
  end

  target 'LeadKitAdditions iOS Extensions' do
    platform :ios, '9.0'

    pod 'LeadKit/Core-iOS-Extension', :path => '~/Projects/LeadKit/'
    # pod "LeadKit/Core-iOS-Extension", '~> 0.8.0'
  end
end

# If you have slow HDD
ENV['COCOAPODS_DISABLE_STATS'] = "true"
