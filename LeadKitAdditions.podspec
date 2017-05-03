Pod::Spec.new do |s|
  s.name            = "LeadKitAdditions"
  s.version         = "0.0.12"
  s.summary         = "iOS framework with a bunch of tools for rapid development"
  s.homepage        = "https://github.com/NikAshanin/LeadKitAdditions"
  s.license         = "Apache License, Version 2.0"
  s.author          = "Touch Instinct"
  s.platform        = :ios, "9.0"
  s.source          = { :git => "https://github.com/NikAshanin/LeadKitAdditions.git", :tag => s.version }
  s.source_files    = "LeadKitAdditions/LeadKitAdditions/**/*.swift"

  s.dependency "LeadKit", '~> 0.4.6'
  s.dependency "KeychainAccess", '3.0.2'
  s.dependency "IDZSwiftCommonCrypto", '0.9.1'
end
