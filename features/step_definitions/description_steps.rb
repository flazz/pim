NS = {
  'premis' => 'info:lc/xmlns/premis-v2'
}

Given /^I want to describe a file$/ do

  pic = File.join(File.dirname(__FILE__), '..', 'fixtures', "wip.png")
  @file = Rack::Test::UploadedFile.new(pic, 'image/png', true)
end

Given /^I provide an object identifier and an ieid$/ do
  @id_type = "URI"
  @id_value = "info:fcla/code/pim/wip.png"
  
  @ieid_type = "URI"
  @ieid_value = "info:fcla/code/pim"
end

When /^I press describe$/ do
  post '/describe/results', { 'document' => @file, 
                              'id_type' => @id_type,
                              'id_value' => @id_value,
                              'ieid_type' => @ieid_type,
                              'ieid_value' => @ieid_value }

end

Then /^it should have an object with an object identifier that matches my input$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('//premis:objectIdentifierType', NS).content.should eql("URI")
  doc.find_first('//premis:objectIdentifierValue', NS).content.should eql("info:fcla/code/pim/wip.png")
end

Then /^it should have an IEID that matches my input$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('//premis:linkingIntellectualEntityIdentifierType', NS).content.should eql("URI")
  doc.find_first('//premis:linkingIntellectualEntityIdentifierValue', NS).content.should eql("info:fcla/code/pim")
end

Then /^all linking objects should have matching identifiers$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('//premis:linkingObjectIdentifierType', NS).content.should eql("URI")
  doc.find_first('//premis:linkingObjectIdentifierValue', NS).content.should eql("info:fcla/code/pim/wip.png")
end

Given /^I don't provide the object identifier type$/ do
  @id_value = "info:fcla/code/pim/wip.png"
  @id_type = nil
end

Then /^I should get an error$/ do
  last_response.status.should == 400
end

Given /^I don't provide the object identifier value$/ do
  @id_type = "URI"
  @id_value = nil 
end

