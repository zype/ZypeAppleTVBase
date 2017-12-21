

Pod::Spec.new do |s|
# 1
s.platform = :tvos
s.tvos.deployment_target = '9.0'
s.name = "ZypeAppleTVBase"
s.summary = "ZypeAppleTVBase lets a user use Zype tvOS SDK."
s.requires_arc = true

# 2
s.version = "0.5.3"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4
s.author = { "Andrey Kasatkin" => "andrey@zype.com" }

# 5
s.homepage = "https://github.com/zype/ZypeAppleTVBase.git"

# 6
s.source = { :git => "https://github.com/zype/ZypeAppleTVBase.git", :tag => "0.5.3"}

# 7
s.framework = "UIKit"

# 8
s.source_files = "ZypeAppleTVBase/**/*.{swift}"

# 9
# s.resources = "ZypeAppleTVBase/**/*.{png,jpeg,jpg,storyboard,xib}"
s.resource_bundles = {
    'ZypeAppleTVBaseResources' => ['ZypeAppleTVBaseResources/**/*.{png,jpeg,jpg,storyboard,xib}']
 }

end
