# Uncomment this line to define a global platform for your project
platform :tvos, '9.0'
use_frameworks!
target 'ZypeAppleTVBase' do
  
end

target 'ZypeAppleTVBaseTests' do
    
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.platform_name == :tvos || target.platform_name == :watchos then
      target.build_configurations.each do |config|
          config.build_settings['ENABLE_BITCODE'] = 'YES'
      end
    end
  end
end
