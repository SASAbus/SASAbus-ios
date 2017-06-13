# Uncomment this line to define a global platform for your project

platform :ios, '9.0'

use_frameworks!

def default_pods
  pod 'DrawerController', '~> 3.1'

  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'

  pod 'zipzap', '~> 8.0.4'

  pod 'KDCircularProgress', '~> 1.2'

  pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :branch => 'swift-3'

  pod 'Alamofire', '~> 4.4'
  pod 'AlamofireNetworkActivityIndicator', '~> 2.0'

  pod 'SwiftyJSON'

  pod 'RxSwift',    '~> 3.0'
  pod 'RxCocoa',    '~> 3.0'

  pod 'RealmSwift'

  pod 'Kingfisher', '~> 3.0'

  pod 'StatefulViewController', '~> 3.0'

  pod 'SSZipArchive'

  pod 'Fabric'
  pod 'Crashlytics'

  pod 'Pulley'

  pod 'ObjectMapper', '~> 2.2'
end

target 'SASAbus' do
    default_pods
end

target 'TripNotification' do
    default_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
