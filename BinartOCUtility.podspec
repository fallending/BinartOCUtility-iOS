#
# Be sure to run `pod lib lint BinartOCUtility.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BinartOCUtility'
  s.version          = '0.2.3'
  s.summary          = 'BinartOCUtility.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'BinartOCUtility more infos.'

  s.homepage         = 'https://github.com/fallending/BinartOCUtility-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fallending' => 'fengzilijie@qq.com' }
  s.source           = { :git => 'https://github.com/fallending/BinartOCUtility-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'BinartOCUtility/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BinartOCUtility' => ['BinartOCUtility/Assets/*.png']
  # }

  s.public_header_files = 'BinartOCUtility/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end


# 1. 开源库发布之后，需要打上tag,参考Git 基础 - 打标签
# git tag -a v1.4 -m 'my version 1.4'
# 2. 进入到项目根目录下，创建podspec文件
# pod spec create PodName
# 3. 编辑podspec文件中的相关信息，有两个比较重要的地方s.source和s.source_files,可以验证是否有误：
# pod spec lint PodName.podspec
# 或者cd 到podspec文件所在目录,执行
# pod lib lint
# 4. 注册pod trunk
# pod trunk register jlc160993@163.com  'sunny冲哥' --description='描述信息'
# 5. 发布到pod trunk
# pod trunk push 
# 该命令在包含有.podspec文件的目录下执行
# 6. 更新pod库
# pod setup