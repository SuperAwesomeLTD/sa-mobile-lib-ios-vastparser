# Be sure to run `pod lib lint SAVASTParser.podspec' to ensure this is a

Pod::Spec.new do |s|
  s.name             = "SAVASTParser"
  s.version          = "1.7.1"
  s.summary          = "The SuperAwesome custom VAST parser"
  s.description      = <<-DESC
		       The SuperAwesome custom VAST parser; built to work with the SAVideoPlayer or the SAVideoVLCPlayer
                       DESC
  s.homepage         = "https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser"
  s.license          = { :type => "GNU GENERAL PUBLIC LICENSE Version 3", :file => "LICENSE" }
  s.author           = { "Gabriel Coman" => "gabriel.coman@superawesome.tv" }
  s.source           = { :git  => "https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser.git", :tag => "1.7.1" }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.dependency 'SAUtils', '1.5.2'
  s.dependency 'SAModelSpace', '0.5.1'
  s.dependency 'SANetworking', '0.3.0'
end
