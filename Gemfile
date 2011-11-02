# A sample Gemfile
source "http://rubygems.org"

gem 'sinatra'
gem 'rjb'
gem 'libxml-ruby', :require => 'libxml'
gem 'libxslt-ruby', '= 1.0.1', :require => 'libxslt'
gem 'semver'
gem "schematron", :git => "git://github.com/cchou/schematron.git", :tag => "v1.1.3"


group :test do
  gem 'cucumber'
  gem 'rspec', :require => "spec"
  gem 'rack-test', :require => 'rack/test'
  gem 'webrat'
  gem 'mock-server'
end

group :thin do
  gem 'thin'
end
