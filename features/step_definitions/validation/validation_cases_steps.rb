Given /^a document with representations not in a digiprovMD or techMD section$/ do
  @doc = fixture_data 'bad_buckets.xml'
end

Then /^I should get some Best Practice errors$/ do
  last_response.body.should include('Document does not conform to PREMIS in METS best practice')
end

Then /^they should include errors about representation placement$/ do
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS representation objects must be contained in a METS techMD or a METS digiprovMD")
end

Given /^a document with bitstream and files not in a techMD section$/ do
  @doc = fixture_data 'bad_buckets.xml'
end

Then /^they should include errors about bitstream and file placement$/ do
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS bitstream and file objects must be contained in a METS techMD")
end

Given /^a document with rights not in a rightsMD section$/ do
  @doc = fixture_data 'bad_buckets.xml'
end

Then /^they should include errors about rights placement$/ do
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS rights must be contained in a METS rightsMD")
end

Given /^a document with events not in a digiprovMD section$/ do
  @doc = fixture_data 'bad_buckets.xml'
end

Then /^they should include errors about event placement$/ do
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS events must be contained in a METS digiprovMD")
end

Given /^a document with agent not in a rightsMD or digiprovMD section$/ do
  @doc = fixture_data 'bad_buckets.xml'
end

Then /^they should include errors about agent placement$/ do
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS agents must be contained in a METS rightsMD if given in a rights context, or in a METS digiprovMD if given in an event context")
end



Given /^a document with the PREMIS root not in a digiprovMD section$/ do
  @doc = fixture_data 'bad_container.xml'
end

Then /^they should include errors about a misplaced PREMIS container$/ do
   last_response.body.gsub(/\s+/, ' ').should include("PREMIS root element must be in a METS digiprovMD")
end

Given /^a document with no container and no buckets$/ do
  @doc = fixture_data 'no_premis.xml'
end

Then /^they should include an error about missing PREMIS$/ do
  last_response.body.gsub(/\s+/, ' ').should include("There must be PREMIS elements inside the METS container.")
end

Given /^a document with a PREMIS container and PREMIS buckets$/ do
  @doc = fixture_data 'bad_container.xml'
end

Then /^they should include an error about choosing either buckets or the container$/ do
  last_response.body.gsub(/\s+/, ' ').should include("If there are multiple PREMIS sections, there should not be a PREMIS root node. Otherwise, all PREMIS elements must be inside the PREMIS root node.")
end

Given /^a document with more than one agent wrapped in a rightsMD section$/ do
  @doc = fixture_data 'double_agent.xml'
end

Then /^they should include an error about keeping agents in separate buckets$/ do
  last_response.body.gsub(/\s+/, ' ').should include("Each PREMIS agent should be in its own digiprovMD or rightsMD section")
end

Given /^a document with PREMIS IDRefs referencing METS buckets$/ do
  @doc = fixture_data 'bad_refs.xml'
end

Then /^they should include errors about overlapping references$/ do
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS attribute RelEventXmlID should not link to a METS element.")
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS attribute RelObjectXmlID should not link to a METS element.")
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS attribute LinkObjectXmlID should not link to a METS element.")
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS attribute LinkEventXmlID should not link to a METS element.")
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS attribute LinkAgentXmlID should not link to a METS element.")
  last_response.body.gsub(/\s+/, ' ').should include("PREMIS attribute LinkPermissionStatementXmlID should not link to a METS element.")
end

Given /^a valid document with unreferenced PREMIS buckets$/ do
  @doc = fixture_data 'bad_buckets.xml'
end

Then /^I should get some Best Practice warnings$/ do
  last_response.body.should include("WARNING")
end
