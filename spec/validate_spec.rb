require 'spec'
require 'spec/interop/test'
require 'sinatra/test'
require 'cgi'

require 'app'

set :environment, :test

describe 'PiM validation' do
  include Sinatra::Test
  
  before do
    @pim_data = IO.read('spec/fixtures/pim/case1.xml')
    @pim_url = CGI::escape 'http://github.com/flazz/pim/raw/cd893cbb869c31f402391cdf53f0bba20218a2e2/sinatra-spike/spec/fixtures/pim/case2.xml'
  end

  describe "input methods" do

    it "should accept a GET with a query parameter referencing the URL of a PiM" do
      get "/validate", :document => @pim_url
      response.should be_ok
    end

    it "should accept a POST with a form encoded PiM"
    # post "/validate", :document => { :tempfile => @pim_tempfile }    
    
    it "should accept a POST with a PiM as the body" do
      post "/validate", :document => @pim_data
      response.should be_ok
    end

  end

  describe "output formats" do

    it "should provide HTML, XML, JSON" do

      %w{text/html application/xml application/json}.each do |mtype|
        post "/validate", {:document => @pim_data}, {:accept => mtype}
        headers['Content-Type'].should == mtype
      end
      
    end

  end

end
