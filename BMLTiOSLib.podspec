# pod lib lint BMLTiOSLib.podspec

Pod::Spec.new do |s|
  s.name             = 'BMLTiOSLib'
  s.version          = '1.1.0'
  s.summary          = 'An iOS Framework that provides a driver-level interaction with BMLT Root Servers.'
  s.description      = 'The BMLTiOSLib is a Swift shared framework designed to allow easy development of iOS BMLT apps.  completely abstracts the connection to BMLT Root Servers, including administration functions.'
  s.homepage         = 'https://bmlt.magshare.net/BMLTiOSLib'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'BMLT Administrators' => 'bmlt@magshare.net' }
  s.source           = { :git => 'https://github.com/LittleGreenViper/BMLTiOSLib.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/LilGreenViper'
  s.ios.deployment_target = '9.0'
  s.source_files = 'BMLTiOSLib/Classes/**/*'
end
