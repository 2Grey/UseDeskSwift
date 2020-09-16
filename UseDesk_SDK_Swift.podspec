Pod::Spec.new do |s|

	s.name             = 'UseDesk_SDK_Swift'
	s.version          = '0.4.3'
	s.summary          = 'A short description of UseDesk.'

	s.description      = <<-DESC
						TODO: Add long description of the pod here.
	                   DESC

	s.homepage         = 'https://github.com/usedesk/UseDeskSwift'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'serega@budyakov.com' => 'kon.sergius@gmail.com' }
	s.source           = { :git => 'https://github.com/usedesk/UseDeskSwift.git', :tag => s.version.to_s }

	s.ios.deployment_target = '11.0'
	s.swift_version = '5.0'
	s.static_framework = true

	s.ios.source_files = 'Sources/Classes/**/*.{m,h,swift}'

	s.resources = [
		'Sources/Assets/**/*.{png,xcassets,imageset,jpeg,jpg}',
		'Sources/Classes/**/*.{storyboard,xib,bundle}',
		'./**/*.{md}'
	]

	s.frameworks = 'UIKit', 'MapKit' ,'AVFoundation'

	s.dependency 'MBProgressHUD', '~> 1.0'
	s.dependency 'Socket.IO-Client-Swift', '~> 14.0'
	s.dependency 'Alamofire', '~> 4.0'
	s.dependency 'QBImagePickerController', '~> 3.4'
	s.dependency 'SDWebImage', '~> 4.0'
end
