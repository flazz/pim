gem 'rack-test', '~>0.3.0'
require 'rack/test'

gem 'webrat', '~>0.4.2'
require 'webrat/sinatra'

# path to schematron
$:.unshift File.join(File.dirname(__FILE__), '../../../schematron/lib')

$:.unshift File.dirname(__FILE__)
require 'app'

require 'spec/expectations'

# require File.expand_path(File.dirname(__FILE__)+'/../../spec_helper')

Pim::App.set :environment, :development

World do
  
  def app
    @app = Rack::Builder.new do
      run Pim::App
    end
  end
  
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  
end
