source 'https://cdn.cocoapods.org/'
source "https://github.com/TouchInstinct/Podspecs.git"

abstract_target 'LeadKitAdditions' do
  pod "KeychainAccess", '~> 4.2.0'
  pod "CryptoSwift", "~> 1.4.0"
  pod "SwiftValidator", '4.0.2'
  pod "SwiftLint", '~> 0.45.0'
  pod "PinLayout", '~> 1.6'

  inhibit_all_warnings!
  use_frameworks!

  target 'LeadKitAdditions iOS' do
    platform :ios, '10.0'

    pod 'LeadKit', '~> 1.7.0'
  end
end

# If you have slow HDD
ENV['COCOAPODS_DISABLE_STATS'] = "true"
