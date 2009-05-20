gem 'rack-test', '~>0.3.0'
require 'rack/test'

gem 'webrat', '~>0.4.2'
require 'webrat/sinatra'

# path to schematron
$:.unshift File.join(File.dirname(__FILE__), '../../../schematron/lib')

# setup the app

app_file = File.join(File.dirname(__FILE__), '../../app.rb')
require app_file
Pim::App.app_file = app_file

require 'spec/expectations'

Pim::App.set :environment, :test

World do
  
  def app
    Pim::App
  end
  
  include Rack::Test::Methods  
  include Webrat::Methods
  include Webrat::Matchers
end
