require 'nokogiri'

NS = {
       'mets' => 'http://www.loc.gov/METS/',
       'premis' => 'info:lc/xmlns/premis-v2'
     }

Given /^a PREMIS document$/ do
  file = File.join(File.dirname(__FILE__), '..', '..', 'spec/fixtures/pim', 
                    'premis1.xml')
  @doc = Rack::Test::UploadedFile.new(file)
end

Given /^I want a premis container$/ do
  @embedding = "container"
end

When /^I convert it$/ do
  post '/convert', { :document => @doc, :convert => "p2pim", 
                     :embed_as => @embedding }
end

Then /^a METS document should be returned$/ do
  pending
  last_response.status.should == 200
  last_response.body.should contain('</mets>')
end

Then /^it should have a single PREMIS container within a METS digiprovMD section$/ do
  pending
  mets_doc = last_response.body.match(/\<mets.*\<\/mets\>/m)
  mets_doc.should_not be_nil
  
  mets = Nokogiri::XML::Document.parse(mets_doc[0])
  mets.should have_xpath('//mets:digiprovMD//premis:premis', NS)
  mets.xpath('//premis:premis', NS).length.should == 1
  
end
