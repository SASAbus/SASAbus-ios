# Uncomment this line to define a global platform for your project

platform :ios, '9.0'

use_frameworks!

target 'SASAbus' do
  pod 'DrawerController', '~> 3.1'
  pod 'Google/Analytics', '~> 1.0.0'
  pod 'zipzap', '~> 8.0.4'
  pod 'KDCircularProgress', '~> 1.2'

  pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :branch => 'swift-3'

  pod 'Alamofire', '~> 4.4'
  pod 'Alamofire-SwiftyJSON', :git => 'https://github.com/SwiftyJSON/Alamofire-SwiftyJSON', :branch => 'master'

  pod 'RxSwift',    '~> 3.0'
  pod 'RxCocoa',    '~> 3.0'

  pod 'RealmSwift'
  
  pod 'Log'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

