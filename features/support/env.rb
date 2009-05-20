gem 'rack-test', '~>0.3.0'
require 'rack/test'

gem 'webrat', '~>0.4.2'
require 'webrat/sinatra'

$:.unshift File.dirname(__FILE__)
require 'app'

# require File.expand_path(File.dirname(__FILE__)+'/../../spec_helper')

Pim.set :environment, :development

World do
  
  def app
    @app = Rack::Builder.new do
      run Pim
    end
  end
  
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
end
