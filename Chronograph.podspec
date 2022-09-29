Pod::Spec.new do |spec|
  spec.name         = "Chronograph"
  spec.version      = "0.0.4"
  spec.summary      = "Chronograph is just the library to use on SwiftUI"
  spec.description  = <<-DESC
Chronograph is just the library to use on SwiftUI
                   DESC

  spec.homepage     = "https://github.com/kksys/#{spec.name}"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "kksys" => "kk.systems.develop@gmail.com" }
  spec.social_media_url   = "https://twitter.com/kksys"
  spec.source       = { :http => "https://github.com/kksys/#{spec.name}/releases/download/#{spec.version}/#{spec.name}-#{spec.version}.zip" }

  spec.requires_arc          = true

  spec.ios.deployment_target = "15.0"
  spec.osx.deployment_target = "12.0"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  spec.vendored_frameworks = "#{spec.name}.xcframework"

  spec.cocoapods_version = ">= 1.9.0"

  spec.swift_version = "5.0"

end
