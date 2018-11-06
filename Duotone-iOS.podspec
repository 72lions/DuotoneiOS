#
# Be sure to run `pod lib lint Duotone-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Duotone-iOS'
  s.version          = '1.0.0'
  s.summary          = 'Spotify\'s new brand identity is full of bright colours. Here is the same effect in iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Spotify's new brand identity is full of bright colours. Here is the same effect in iOS.
                       DESC

  s.homepage         = 'https://github.com/QuentinArnault/Duotone-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'QuentinArnault' => 'quentin.arnault@gmail.com' }
  s.source           = { :git => 'https://github.com/QuentinArnault/Duotone-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.4'

  s.source_files = 'Duotone-iOS/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Duotone-iOS' => ['Duotone-iOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
