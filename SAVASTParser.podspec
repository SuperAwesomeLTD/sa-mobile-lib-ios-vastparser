# Be sure to run `pod lib lint SAVASTParser.podspec' to ensure this is a

Pod::Spec.new do |s|
  s.name             = "SAVASTParser"
  s.version          = "1.0.8"
  s.summary          = "The SuperAwesome custom VAST parser"
  s.description      = <<-DESC
		       The SuperAwesome custom VAST parser; built to work with the SAVideoPlayer or the SAVideoVLCPlayer
                       DESC
  s.homepage         = "https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser"
  s.license          = { :type => "GNU GENERAL PUBLIC LICENSE Version 3", :file => "LICENSE" }
  s.author           = { "Gabriel Coman" => "gabriel.coman@superawesome.tv" }
  s.source           = { :git => "https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser.git", :tag => "1.0.8" }
  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SAVASTParser' => ['Pod/Assets/*.png']
  }
  s.dependency 'SAUtils'
  s.dependency 'SAVideoPlayer'
  s.dependency 'SAEvents'
end
