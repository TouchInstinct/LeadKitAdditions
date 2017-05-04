Pod::Spec.new do |s|
  s.name            = "LeadKitAdditions"
  s.version         = "0.0.13"
  s.summary         = "iOS framework with a bunch of tools for rapid development"
  s.homepage        = "https://github.com/NikAshanin/LeadKitAdditions"
  s.license         = "Apache License, Version 2.0"
  s.author          = "Touch Instinct"
  s.platform        = :ios, "9.0"
  s.source          = { :git => "https://github.com/NikAshanin/LeadKitAdditions.git", :tag => s.version }

  s.subspec 'Core' do |ss|
    ss.source_files = "LeadKitAdditions/Sources/**/*.swift"

    ss.dependency "LeadKit", '0.5.0'
    ss.dependency "KeychainAccess", '3.0.2'
    ss.dependency "IDZSwiftCommonCrypto", '0.9.1'
  end

  s.subspec 'Core-iOS-Extension' do |ss|
    ss.source_files = "LeadKitAdditions/Sources/**/*.swift"

    ss.dependency "LeadKit/Core-iOS-Extension", '0.5.0'
    ss.dependency "KeychainAccess", '3.0.2'
    ss.dependency "IDZSwiftCommonCrypto", '0.9.1'
  end

  s.default_subspec = 'Core'

end
