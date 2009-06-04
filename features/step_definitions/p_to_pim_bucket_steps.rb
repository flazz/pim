Given /^I want PREMIS elements sorted into specific METS buckets$/ do
  @embedding = "buckets"
end

Then /^it should have PREMIS object in METS techMD section$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('//mets:techMD//mets:xmlData/premis:object', XMLNS).should_not be_nil
end

Then /^it should have PREMIS events in METS digiprovMD section$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('//mets:digiprovMD//mets:xmlData/premis:event', XMLNS).should_not be_nil
end

Then /^it should have PREMIS agents in METS digiprovMD section$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('//mets:digiprovMD//mets:xmlData/premis:agent', XMLNS).should_not be_nil
end

Then /^it should have PREMIS rights in METS rightsMD section$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('//mets:rightsMD//mets:xmlData/premis:rights', XMLNS).should_not be_nil
end


Then /^a choice of potential representations will be returned$/ do
  pending
end
