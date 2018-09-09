# CocoaPods master specs repo
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Bamilo' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for Bamilo
  pod 'Adjust'
  pod 'Fabric'
  pod 'EmarsysPredictSDK'
  pod 'Crashlytics', '~> 3.9'
  pod 'FXBlurView','~> 1.6.4'
  pod 'GoogleTagManager', '3.15.0' # ********** Legacy
  pod 'GoogleAnalytics', '3.14.0' # ********** Legacy
  pod 'GoogleAppIndexing','~> 2.0.3'
  pod 'MobileEngageSDK'
  pod 'JBWhatsAppActivity', '~> 1.0'
  pod 'SDWebImage', '~> 3.8'
  pod 'TTRangeSlider', '~> 1.0.5'
  pod 'M13Checkbox'
  pod 'JSONModel'
  pod 'CHIPageControl/Jalapeno'
  pod 'RAlertView'
  pod 'Pushwoosh'
  pod 'AnimatedCollectionViewLayout'
  pod 'ObjectMapper'
  pod 'SwiftyJSON'
  pod 'Kingfisher'
  pod 'Alamofire'
  pod 'AlamofireObjectMapper'
  pod 'RealmSwift'
  pod 'FSPagerView'
  pod 'TBActionSheet'
  pod 'ImageViewer'
  pod 'UICircularProgressRing'
  pod 'Firebase/Core'
  pod 'Firebase/Performance'

  target 'BamiloUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  post_install do |installer|
      installer.pods_project.build_configurations.each do |config|
          config.build_settings.delete('CODE_SIGNING_ALLOWED')
          config.build_settings.delete('CODE_SIGNING_REQUIRED')
      end
  end

end
