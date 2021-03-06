# Uncomment this line to define a global platform for your project

use_frameworks!


def shared
  pod 'RealmSwift'

  pod 'ObjectMapper', '~> 2.2'

  pod 'SwiftyBeaver'
end


def default_pods
  platform :ios, '10.0'

  pod 'DrawerController', '~> 3.1'

  pod 'Firebase/Core', '~> 4.1.0'
  pod 'Firebase/Messaging', '~> 4.1.0'
  pod 'Firebase/RemoteConfig', '~> 4.1.0'

  pod 'Google/SignIn'

  pod 'zipzap', '~> 8.0.4'

  pod 'KDCircularProgress', '~> 1.2'

  pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :branch => 'swift-3'

  pod 'AlamofireNetworkActivityIndicator', '~> 2.0'

  pod 'Kingfisher', '~> 3.0'

  pod 'StatefulViewController', '~> 3.0'

  pod 'Fabric'
  pod 'Crashlytics', '~>  3.8'

  pod 'Pulley', :git => 'https://github.com/52inc/Pulley.git', :branch => 'swift-3.1'

  pod 'LocationPickerViewController'

  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'

  pod 'PolyglotLocalization'

  pod 'Permission/Notifications'
  pod 'Permission/Location'

  pod 'SSZipArchive'

  pod 'Alamofire', '~> 4.4'

  pod 'SwiftyJSON'

  pod 'RxSwift',    '~> 3.0'
  pod 'RxCocoa',    '~> 3.0'
end


target 'SASAbus' do
    default_pods
    shared
end


target 'TripNotification' do
    default_pods
    shared
end


target 'SASAbus Watch Extension' do
  platform :watchos, '4.0'

  shared
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'SASAbus Watch Extension'
            target.build_configurations.each do |config|
                  config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
            end
        end

        if target.name == 'SASAbus'
            target.build_configurations.each do |config|
                  config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
            end
        end
    end
end
