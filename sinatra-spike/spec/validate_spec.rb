require 'app'  # <-- your sinatra app
require 'spec'
require 'spec/interop/test'
require 'sinatra/test'
require 'cgi'

set :environment, :test

describe 'PiM validation' do
  include Sinatra::Test

  before do
    @pim_data = nil
    @pim_url = CGI::escape 'http://a/premis/in/mets/document'
  end

  describe "input methods" do

    it "should accept a GET with a query parameter referencing the URL of a PiM" do
      get "/validate", :document => @pim_url
      response.should be_ok
    end

    it "should accept a POST with a form encoded PiM" do
      post "/validate", :document => @pim_data
      response.should be_ok
    end

    it "should accept a POST with a PiM as the body"

  end

  describe "output formats" do

    it "should provide HTML, text, XML, JSON" do

      %w{text/html text/plain text/xml application/json}.each do |mtype|
        post "/validate", :document => @pim_url, :accept => mtype
        headers['Content-Type'].should == mtype
      end
      
    end

  end

end
