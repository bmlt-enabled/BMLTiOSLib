Pod::Spec.new do |spec|
    spec.name                       = 'BMLTiOSLib'
    spec.summary                    = 'An iOS Framework that provides a driver-level interaction with BMLT Root Servers.'
    spec.description                = 'The BMLTiOSLib is a Swift shared framework designed to allow easy development of iOS BMLT apps. It completely abstracts the connection to BMLT Root Servers, including administration functions.'
    spec.version                    = '1.2.14'
    spec.platform                   = :ios, '11.0'
    spec.homepage                   = 'https://bmlt.app/BMLTiOSLib'
    spec.social_media_url           = 'https://twitter.com/BMLT_NA'
    spec.author                     = { 'BMLT Administrators' => 'admin@bmlt.app' }
    spec.documentation_url          = 'https://bmlt-enabled.github.io/BMLTiOSLib/'
    spec.license                    = { :type => 'MIT', :file => 'LICENSE' }
    spec.source                     = { :git => 'https://github.com/bmlt-enabled/BMLTiOSLib.git', :tag => spec.version.to_s }
    spec.source_files               = 'BMLTiOSLib/Framework Project/Classes/**/*'
    spec.dependency                'SwiftLint', '~> 0.24'
    spec.swift_version              = '5.0'
end

