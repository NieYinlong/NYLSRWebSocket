#
# Be sure to run `pod lib lint NYLSRWebSocket.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NYLSRWebSocket'
  s.version          = '0.0.1'
  s.summary          = '针对SRWebSocket的封装'
  s.homepage         = 'https://github.com/nieyinlong/NYLSRWebSocket'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nieyinlong' => 'nyl0819@126.com' }
  s.source           = { :git => 'https://github.com/nieyinlong/NYLSRWebSocket.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'NYLSRWebSocket/Classes/**/*'
  s.dependency 'SocketRocket', '~> 0.5.1'
  s.dependency 'AFNetworking', '3.1.0'
  s.dependency 'SVProgressHUD', '2.0.3'
end
