Pod::Spec.new do |s|
  s.name            = "LeadKitAdditions"
  s.version         = "0.4.0"
  s.summary         = "iOS framework with a bunch of tools for rapid development"
  s.homepage        = "https://github.com/TouchInstinct/LeadKitAdditions"
  s.license         = "Apache License, Version 2.0"
  s.author          = "Touch Instinct"
  s.platform        = :ios, "10.0"
  s.source          = { :git => "https://github.com/TouchInstinct/LeadKitAdditions.git", :tag => s.version }

  s.subspec 'Core' do |ss|
    ss.ios.deployment_target = '10.0'
    ss.source_files = "Sources/**/*.swift"

    ss.dependency "LeadKit", '~> 1.7.0'
    ss.dependency "KeychainAccess", '~> 4.2.0'
    ss.dependency "CryptoSwift", '~> 1.4.0'
    ss.dependency "SwiftValidator", '4.0.2'
  end

  s.default_subspec = 'Core'

end
