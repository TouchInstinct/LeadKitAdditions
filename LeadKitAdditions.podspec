Pod::Spec.new do |s|
  s.name            = "LeadKitAdditions"
  s.version         = "0.0.23"
  s.summary         = "iOS framework with a bunch of tools for rapid development"
  s.homepage        = "https://github.com/TouchInstinct/LeadKitAdditions"
  s.license         = "Apache License, Version 2.0"
  s.author          = "Touch Instinct"
  s.platform        = :ios, "9.0"
  s.source          = { :git => "https://github.com/TouchInstinct/LeadKitAdditions.git", :tag => s.version }

  s.subspec 'Core' do |ss|
    ss.ios.deployment_target = '9.0'
    ss.source_files = "LeadKitAdditions/Sources/**/*.swift"

    ss.exclude_files = [
      "LeadKitAdditions/Sources/Services/Network/DefaultNetworkService+ActivityIndicator+Extension.swift",
    ]

    ss.dependency "LeadKit", '~> 0.5' # till 0.6
    ss.dependency "KeychainAccess", '3.0.2'
    ss.dependency "IDZSwiftCommonCrypto", '0.9.1'
    ss.dependency "InputMask", '2.2.5'
    ss.dependency "SwiftValidator", '4.0.0'
  end

  s.subspec 'Core-iOS-Extension' do |ss|
    ss.platform = :ios, '9.0'
    ss.source_files = "LeadKitAdditions/Sources/**/*.swift"

    ss.exclude_files = [
      "LeadKitAdditions/Sources/Services/Network/DefaultNetworkService+ActivityIndicator.swift",
    ]

    ss.dependency "LeadKit/Core-iOS-Extension", '~> 0.5'
    ss.dependency "KeychainAccess", '3.0.2'
    ss.dependency "IDZSwiftCommonCrypto", '0.9.1'
    ss.dependency "InputMask", '2.2.5'
    ss.dependency "SwiftValidator", '4.0.0'
  end

  s.default_subspec = 'Core'

end
