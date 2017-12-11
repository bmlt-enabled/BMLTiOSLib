Pod::Spec.new do |spec|
    spec.name                       = 'BMLTiOSLib'
    spec.version                    = '1.2.0'
    spec.summary                    = 'An iOS Framework that provides a driver-level interaction with BMLT Root Serverspec.'
    spec.description                = 'The BMLTiOSLib is a Swift shared framework designed to allow easy development of iOS BMLT appspec. It completely abstracts the connection to BMLT Root Servers, including administration functionspec.'
    spec.homepage                   = 'https://bmlt.magshare.net/BMLTiOSLib'
    spec.documentation_url          = 'https://bmlt.magshare.net/bmlt-doc/'
    spec.license                    = { :type => 'MIT', :file => 'LICENSE' }
    spec.author                     = { 'BMLT Administrators' => 'bmlt@magshare.net' }
    spec.source                     = { :git => 'https://github.com/LittleGreenViper/BMLTiOSLib.git', :tag => spec.version.to_s }
    spec.social_media_url           = 'https://twitter.com/BMLT_NA'
    spec.ios.deployment_target      = '9.0'
    spec.source_files               = 'BMLTiOSLib/Framework Project/Classes/**/*'
    spec.dependency                'SwiftLint'
end

