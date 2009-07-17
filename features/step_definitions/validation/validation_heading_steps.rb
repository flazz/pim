Given /^a document is not well formed$/ do
  @doc = fixture_data 'not_well_formed.xml'
end

Then /^all headings except well formedness are visually disabled$/ do
  last_response.should match_selector('h2:not(.disabled)', :content  => 'document is not well-formed')
  last_response.should match_selector('h2.disabled', :content  => 'validity (not performed)')
  last_response.should match_selector('h2.disabled', :content  => 'PREMIS in METS best practice conformance (not performed)')
end

Given /^a document is not valid$/ do
  @doc = fixture_data 'pim_invalid.xml'
end

Then /^only best practice heading is visually disabled$/ do
  last_response.should match_selector('h2:not(.disabled)', :content  => 'document is well-formed')
  last_response.should match_selector('h2:not(.disabled)', :content  => 'document is invalid')
  last_response.should match_selector('h2.disabled', :content  => 'PREMIS in METS best practice conformance (not performed)')  
end

Given /^a valid xml document$/ do
  @doc = fixture_data 'pim_buckets.xml'
end

Then /^nothing is visually disabled$/ do
  last_response.should match_selector('h2:not(.disabled)', :content  => 'document is well-formed')
  last_response.should match_selector('h2:not(.disabled)', :content  => 'document is valid')
  last_response.should match_selector('h2:not(.disabled)', :content  => 'document conforms to PREMIS in METS best practice')  
end
