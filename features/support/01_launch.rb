########################################
#                                      #
#       Important Note                 #
#                                      #
#   When running calabash-ios tests at #
#   www.xamarin.com/test-cloud         #
#   the  methods invoked by            #
#   CalabashLauncher are overriden.    #
#   It will automatically ensure       #
#   running on device, installing apps #
#   etc.                               #
#                                      #
########################################

require 'calabash-cucumber/launcher'


# APP_BUNDLE_PATH = "~/Library/Developer/Xcode/DerivedData/??/Build/Products/Calabash-iphonesimulator/??.app"
# You may uncomment the above to overwrite the APP_BUNDLE_PATH
# However the recommended approach is to let Calabash find the app itself
# or set the environment variable APP_BUNDLE_PATH
APP_BUNDLE_PATH = "/Users/rocket/Workspace/Jenkins/workspace/Jumia_Calabash_iOS_1.0_NG/TestBuild/Jumia-cal.app"

Before do |scenario|
    result1 = system('defaults write ~/Library/Developer/CoreSimulator/Devices/AB94AC36-2D5B-4C5E-A131-D17B3824516E/data/Library/Preferences/com.apple.Preferences.plist KeyboardAutocapitalization -bool NO')
    result2 = system('defaults write ~/Library/Developer/CoreSimulator/Devices/AB94AC36-2D5B-4C5E-A131-D17B3824516E/data/Library/Preferences/com.apple.Preferences.plist KeyboardAutocorrection -bool NO')
    result3 = system('defaults write ~/Library/Developer/CoreSimulator/Devices/AB94AC36-2D5B-4C5E-A131-D17B3824516E/data/Library/Preferences/com.apple.Preferences.plist KeyboardCheckSpelling -bool NO')
    result4 = system('defaults write ~/Library/Developer/CoreSimulator/Devices/AB94AC36-2D5B-4C5E-A131-D17B3824516E/data/Library/Preferences/com.apple.Preferences.plist KeyboardPrediction -bool NO')
    puts "#{result1}, #{result2}, #{result3}, #{result4}"
  @calabash_launcher = Calabash::Cucumber::Launcher.new
  unless @calabash_launcher.calabash_no_launch?
    @calabash_launcher.relaunch
    @calabash_launcher.calabash_notify(self)
  end
end

After do |scenario|
  unless @calabash_launcher.calabash_no_stop?
    calabash_exit
    if @calabash_launcher.active?
      @calabash_launcher.stop
    end
  end
end

at_exit do
  launcher = Calabash::Cucumber::Launcher.new
  if launcher.simulator_target?
    launcher.simulator_launcher.stop unless launcher.calabash_no_stop?
  end
end
