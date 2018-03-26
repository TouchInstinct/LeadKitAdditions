source "https://github.com/CocoaPods/Specs.git"
source "https://github.com/TouchInstinct/Podspecs.git"

abstract_target 'LeadKitAdditions' do
  pod "KeychainAccess", '3.1.0'
  pod "IDZSwiftCommonCrypto"
  pod "InputMask", '3.0.0'
  pod "SwiftValidator", '5.0.0'
  pod "SwiftLint", '~> 0.25'

  inhibit_all_warnings!

  target 'LeadKitAdditions iOS' do
    platform :ios, '9.0'

    use_frameworks!

    pod 'LeadKit', :git => 'https://github.com/TouchInstinct/LeadKit', :branch => 'feature/text_field_view_model'
  end

  target 'LeadKitAdditions iOS Extensions' do
    platform :ios, '9.0'

    use_frameworks!

    pod "LeadKit/Core-iOS-Extension", :git => 'https://github.com/TouchInstinct/LeadKit', :branch => 'feature/text_field_view_model'
  end
end

# If you have slow HDD
ENV['COCOAPODS_DISABLE_STATS'] = "true"
