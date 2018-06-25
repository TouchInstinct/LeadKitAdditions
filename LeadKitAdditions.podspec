Pod::Spec.new do |s|
  s.name            = "LeadKitAdditions"
  s.version         = "0.3.1"
  s.summary         = "iOS framework with a bunch of tools for rapid development"
  s.homepage        = "https://github.com/TouchInstinct/LeadKitAdditions"
  s.license         = "Apache License, Version 2.0"
  s.author          = "Touch Instinct"
  s.platform        = :ios, "9.0"
  s.source          = { :git => "https://github.com/TouchInstinct/LeadKitAdditions.git", :tag => s.version }

  s.subspec 'Core' do |ss|
    ss.ios.deployment_target = '9.0'
    ss.source_files = "Sources/**/*.swift"

    ss.exclude_files = [
      "Sources/Services/Network/DefaultNetworkService+ActivityIndicator+Extension.swift",
    ]

    ss.dependency "LeadKit", '~> 0.8.0'
    ss.dependency "KeychainAccess", '3.1.0'
    ss.dependency "CryptoSwift", '~> 0.9.0'
    ss.dependency "SwiftValidator", '5.0.0'
    ss.dependency "PinLayout", '~> 1.6'
  end

  s.subspec 'Core-iOS-Extension' do |ss|
    ss.platform = :ios, '9.0'
    ss.source_files = "Sources/**/*.swift"

    ss.exclude_files = [
      "Sources/Classes/Cells/LabelTableViewCell/*.swift",
      "Sources/Services/Network/DefaultNetworkService+ActivityIndicator.swift",
      "Sources/Extensions/Cells/**/*.swift"
    ]

    ss.dependency "LeadKit/Core-iOS-Extension", '~> 0.8.0'
    ss.dependency "KeychainAccess", '3.1.0'
    ss.dependency "CryptoSwift", '~> 0.9.0'
    ss.dependency "SwiftValidator", '5.0.0'
    ss.dependency "PinLayout", '~> 1.6'
  end

  s.default_subspec = 'Core'

end
