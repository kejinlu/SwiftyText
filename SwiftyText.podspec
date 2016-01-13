Pod::Spec.new do |s|
  s.name = 'SwiftyText'
  s.version = '0.0.2'
  s.license = 'MIT'
  s.summary = 'SwiftyText in Swift based on Text Kit'
  s.homepage = 'https://github.com/kejinlu/SwiftyText'
  s.social_media_url = 'http://weibo.com/kejinlu'
  s.authors = { 'Luke' => 'kejinlu@gmail.com' }
  s.source = { :git => 'https://github.com/kejinlu/SwiftyText.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'SwiftyText/**/*.swift'

  s.requires_arc = true
end