require 'cgi'

Given /^I enter a url to a PiM document$/ do
  @url = CGI::escape('http://wiki.fcla.edu:8000/TIPR/uploads/3/fda_tipr.xml')
end

Given /^I select to upload a PiM document file$/ do

  file = File.join(File.dirname(__FILE__), '..', '..', 'spec/fixtures/pim', 
                    'case1.xml')
  @doc = Rack::Test::UploadedFile.new(file)

end

Given /^I enter PiM XML in the text area$/ do

  # A generic XML file
  @doc = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<foo>
  <name>Foo</name>
  <description>I am not a PiM document</description>
</foo>
XML

end

When /^I validate (.*)$/ do |type|

  case type
    when 'the url'
      pending "Getting error: undefined method `initialize_http_header'. Seems to originate from app.rb"
      get('/validate', :document => @url )
    else
      post('/validate', :document => @doc )
  end
  
end
