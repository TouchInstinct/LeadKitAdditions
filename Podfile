source "https://github.com/CocoaPods/Specs.git"
source "https://github.com/TouchInstinct/Podspecs.git"

abstract_target 'LeadKitAdditions' do
  pod "KeychainAccess", '3.1.0'
  pod "CryptoSwift", "~> 0.9.0"
  pod "SwiftValidator", '5.0.0'
  pod "SwiftLint", '~> 0.25'
  pod "PinLayout"

  inhibit_all_warnings!

  target 'LeadKitAdditions iOS' do
    platform :ios, '10.0'

    use_frameworks!

    pod 'LeadKit', :git => 'https://github.com/TouchInstinct/LeadKit.git', :branch => 'feature/swift4.2'
  end

  target 'LeadKitAdditions iOS Extensions' do
    platform :ios, '10.0'

    use_frameworks!

    pod "LeadKit/Core-iOS-Extension", :git => 'https://github.com/TouchInstinct/LeadKit.git', :branch => 'feature/swift4.2'
  end
end

# If you have slow HDD
ENV['COCOAPODS_DISABLE_STATS'] = "true"

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'LeadKit' or target.name == 'LeadKit-Core-iOS-Extensions'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
        else
			target.build_configurations.each do |config|
				config.build_settings['SWIFT_VERSION'] = '4.0'
			end
		end
    end
end
