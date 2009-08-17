XMLNS = {
  'mets' => 'http://www.loc.gov/METS/',
  'premis' => 'info:lc/xmlns/premis-v2'
}

Given /^a PREMIS document$/ do
  @doc = fixture_data 'simple_premis.xml'
end

Given /^I want a premis container$/ do
  @use_premis_container = "on"
end

When /^I convert it$/ do
  post '/convert/results', 'document' => @doc, 'use-premis-container' => @use_premis_container
end

Then /^a METS document should be returned$/ do
  last_response.status.should == 200
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('/mets:mets', XMLNS).should_not be_nil
end

Then /^it should have a single PREMIS container within a METS digiprovMD section$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('//mets:digiprovMD//premis:premis', XMLNS).should_not be_nil
end

# bucket specific
Given /^I want PREMIS elements sorted into specific METS buckets$/ do
  @use_premis_container = nil
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

Then /^a PREMIS document should be returned$/ do
  last_response.status.should == 200
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('/premis:premis', XMLNS).should_not be_nil
  doc.find_first('/premis:premis/premis:object', XMLNS).should_not be_nil
end

Given /^a PREMIS\-in\-METS document with PREMIS embedded as a container$/ do  
  @doc = fixture_data 'pim_container.xml'
end

Given /^a PREMIS\-in\-METS document with PREMIS embedded as buckets$/ do
  @doc = fixture_data 'pim_buckets.xml'
end

Given /^an invalid PREMIS\-in\-METS document$/ do
  @doc = fixture_data 'pim_invalid.xml'
end

Then /^some validation errors should be returned$/ do
  last_response.body.should contain('PREMISSSSSSS')
  last_response.body.should have_selector('div#flash', :content => 'Cannot convert: validation errors exist')
end

Then /^the status should be (\d{3})$/ do |n|
  last_response.status.should == n.to_i
end

Then /^it should be valid$/ do
  r = Pim::Validation.new(last_response.body).results
  r[:fatals].should be_empty
  r[:errors].should be_empty
end

Then /^it should conform to PiM BP$/ do
  r = Pim::Validation.new(last_response.body).results
  unless r[:best_practice].empty?
    r[:best_practice].each { |e| e[:rule_type].should == 'report' }
  end
end


# Checking conversion ID/ADMID linking

Given /^a PREMIS document with an object linking to an event$/ do
  @doc = fixture_data 'pim_links.xml'
end

Then /^it should have an object METS bucket with an ADMID reference to an event METS bucket$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  doc.find_first('//mets:techMD[@ID="bitstream-1"]/@ADMID', XMLNS).value.should include 'event-2'
end

Given /^a PREMIS document with an object linking to an object \(and event\) in a relationship$/ do
  @doc = fixture_data 'pim_links.xml'
end

Then /^it should have an object METS bucket with an ADMID reference to an object \(and event\) in a relationship METS bucket$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  admid = doc.find_first('//mets:techMD[@ID="bitstream-1"]/@ADMID', XMLNS).value
  admid.should include('object-2')
  admid.should include('event-1')
end

Given /^a PREMIS document with an event linking to an object$/ do
  @doc = fixture_data 'pim_links.xml'
end

Then /^it should have an event METS bucket with an ADMID reference to an object METS bucket$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  admid = doc.find_first('//mets:digiprovMD[@ID="event-1"]/@ADMID', XMLNS).value
  admid.should include('object-2')
end

Given /^a PREMIS document with an event linking to an agent$/ do
  @doc = fixture_data 'pim_links.xml'
end

Then /^it should have an event METS bucket with an ADMID reference to an agent METS bucket$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  admid = doc.find_first('//mets:digiprovMD[@ID="event-1"]/@ADMID', XMLNS).value
  admid.should include('agent-1')
end

Given /^a PREMIS document with rights linking to an agent$/ do
  @doc = fixture_data 'pim_links.xml'
end

Then /^it should have rights METS bucket with an ADMID reference to an agent METS bucket$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  admid = doc.find_first('//mets:rightsMD[@ID="rights-1"]/@ADMID', XMLNS).value
  admid.should include('agent-1')
end

Given /^a PREMIS document with rights linking to an object$/ do
  @doc = fixture_data 'pim_links.xml'
end

Then /^it should have rights METS bucket with an ADMID reference to an object METS bucket$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  admid = doc.find_first('//mets:rightsMD[@ID="rights-1"]/@ADMID', XMLNS).value
  admid.should include('representation-1')
end

