require 'cgi'

Given /^I enter a url to a PiM document$/ do
  @url = CGI::escape('http://wiki.fcla.edu:8000/TIPR/uploads/3/fda_tipr.xml')
end

Given /^I select to upload a PiM document file$/ do
  file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'case1.xml')
  @doc = Rack::Test::UploadedFile.new(file)
end

Given /^I enter PiM XML in the text area$/ do
  pending
end

When /^I validate (.*)$/ do |type|
  pending
  
  case type
    when 'the url'
      pending "Getting error: undefined method `initialize_http_header'. Seems to originate from app.rb"
      get('/validate', :document => @url )
    else
      post('/validate', :document => @doc )
  end
  
end
