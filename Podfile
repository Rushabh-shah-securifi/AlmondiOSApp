platform :ios, '7.0'

#inhibit_all_warnings!

#link_with 'Almond', 'HomeScreen'

def shared_pods
        pod 'SDWebImage'
	pod 'ASValueTrackingSlider'
	pod 'CocoaLumberjack'
	#pod 'CrashlyticsLumberjack', '~> 2.0.0-rc2'
    pod 'Fabric'
	pod 'Crashlytics'
	pod 'Colours', '~> 5.5'
	pod 'GoogleAnalytics'
	pod 'iToast', '~> 0.0'
	pod 'MBProgressHUD', '~> 0.9'
	pod 'PureLayout'
	pod 'SWRevealViewController', '~> 2.3'
	pod "UIImage-ResizeMagick"
	pod 'V8HorizontalPickerView', '~> 1.0'
	pod 'ActionSheetPicker-3.0'
    pod "GLCalendarView", "~> 1.0.0"
	pod 'Stripe’
end

xcodeproj 'SecurifiApp.xcodeproj'

target 'Almond' do
	shared_pods
end

target 'HomeScreen' do
	shared_pods
end
