require 'spec'
require 'rack/test'
require 'webrat'

# setup the app
app_file = File.join(File.dirname(__FILE__), '../../app.rb')
require app_file

$:.unshift File.join(File.dirname(__FILE__), '../../lib')
require 'validation'

Pim::App.app_file = app_file
 
Webrat.configure do |config|
  config.mode = :rack
end

Pim::App.set :environment, :test

World do
    
  def app
    
    @app = Rack::Builder.new do
      run Pim::App
    end
    
  end
  
  def fixture_file name
    File.join(File.dirname(__FILE__), '..', 'fixtures', name)
  end
  
  def fixture_data name
    file = fixture_file name
    open(file) { |io| io.read }
  end
  
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
end
