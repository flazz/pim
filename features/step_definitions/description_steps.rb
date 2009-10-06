NS = {
  'premis' => 'info:lc/xmlns/premis-v2'
}

Given /^I want to describe a (file|url)$/ do |thing|
  @thing = thing

  pic = File.join(File.dirname(__FILE__), '..', 'fixtures', "wip.png")
  
  case thing
  when "file"  
    @file = Rack::Test::UploadedFile.new(pic, 'image/png', true)
  when "url"
    @url = "http://localhost:4000/wip.png"
  end


end

Given /^I provide an object identifier and an ieid$/ do
  @id_type = "URI"
  @id_value = "info:fcla/code/pim/wip.png"
  
  @ieid_type = "URI"
  @ieid_value = "info:fcla/code/pim"
end

When /^I press describe$/ do
  
  case @thing
  when 'file'
    post '/describe/results', { 'document' => @file, 
      'id_type' => @id_type,
      'id_value' => @id_value,
      'ieid_type' => @ieid_type,
      'ieid_value' => @ieid_value 
    }
  when 'url'
      get '/describe/results', { 'document' => @url, 
        'id_type' => @id_type,
        'id_value' => @id_value,
        'ieid_type' => @ieid_type,
        'ieid_value' => @ieid_value 
      }

    end

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

Then /^it should have an originalName that matches the upload filename or url$/ do
    doc = LibXML::XML::Parser.string(last_response.body).parse
    doc.find_first('//premis:originalName', NS).content.should == case @thing
      when 'file'
        "wip.png"
      when 'url'
        'http://localhost:4000/wip.png'
      end
end

Given /^I want to describe a pdf file$/ do
  @thing = 'file'
  f = File.join(File.dirname(__FILE__), '..', 'fixtures', "00001.pdf")
  @file = Rack::Test::UploadedFile.new(f, 'application/pdf', true)
  
end

Then /^The bitstream ids should be correct$/ do
  
  # one file object
  doc = LibXML::XML::Parser.string(last_response.body).parse
  file_objects = doc.find "//premis:object[@xsi:type='file']", NS
  file_objects.should have_exactly(1).items
  f_type = file_objects.first.find_first('premis:objectIdentifier/premis:objectIdentifierType', NS).content.strip
  f_type.should_not be_empty
  f_value = file_objects.first.find_first('premis:objectIdentifier/premis:objectIdentifierValue', NS).content.strip
  f_value.should_not be_empty
  
  # should be identified
  bs_objects = doc.find "//premis:object[@xsi:type='bitstream']", NS
  bs_objects.should have_at_least(1).items
  bs_ids = bs_objects.map do |bs_o|
    b_type = bs_o.find_first('premis:objectIdentifier/premis:objectIdentifierType', NS).content.strip
    b_type.should_not be_empty
    b_value = bs_o.find_first('premis:objectIdentifier/premis:objectIdentifierValue', NS).content.strip
    b_value.should_not be_empty
    [b_type, b_value]
  end

  # should be no dups
  bs_ids.size.should == bs_ids.uniq.size

  # should start with the file they belong to
  bs_ids.each do |type, value|
    type.should == f_type
    value.should =~ %r{^#{f_value}.+$}
  end

  # relationship ids should match links
  file_links = doc.find "//premis:object[@xsi:type='file']/premis:relationship/premis:linkingObject", NS
  file_links.should have(0).items
end

