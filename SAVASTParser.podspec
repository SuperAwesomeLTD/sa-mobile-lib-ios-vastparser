Pod::Spec.new do |s|
  s.name = 'SAVASTParser'
  s.version = '1.7.5'
  s.summary = 'The SuperAwesome custom VAST parser'
  s.description = <<-DESC
   The SuperAwesome custom VAST parser; built to work with the SAVideoPlayer
                       DESC
  s.homepage = 'https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser'
  s.license = { 
	:type => 'GNU GENERAL PUBLIC LICENSE Version 3', 
	:file => 'LICENSE' 
  }
  s.author = { 
	'Gabriel Coman' => 'gabriel.coman@superawesome.tv' 
  }
  s.source = { 
	:git  => 'https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser.git', 
	:branch => 'master',
	:tag => '1.7.5' 
  }
  s.platform = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.dependency 'SAUtils', '1.5.5'
  s.dependency 'SAModelSpace', '1.0.0'
  s.dependency 'SANetworking', '1.0.0'
end
