Pod::Spec.new do |spec|
  spec.name         = "Chronometer"
  spec.version      = "0.0.1"
  spec.summary      = "Chronometer is just the library to use on SwiftUI"
  spec.description  = <<-DESC
Chronometer is just the library to use on SwiftUI
                   DESC

  spec.homepage     = "https://www.kk-systems.net/library/Chronometer"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "kksys" => "kk.systems.develop@gmail.com" }
  spec.social_media_url   = "https://twitter.com/kksys"
  spec.source       = { :http => "https://www.kk-systems.net/library/Chronometer/Chronometer.zip" }

  spec.requires_arc          = true

  spec.ios.deployment_target = "15.0"
  spec.osx.deployment_target = "12.0"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  spec.vendored_frameworks = "Chronometer.xcframework"

  spec.cocoapods_version = ">= 1.9.0"

  spec.swift_version = "5.0"

end
