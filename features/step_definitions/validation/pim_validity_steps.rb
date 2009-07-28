Given /^I submit a\(n\) (conforming|non-conforming) PiM document$/ do |state|

  @doc = case state
         when 'conforming'
           fixture_data 'pim_buckets.xml'
         when 'non-conforming'
           fixture_data 'pim_non_conform.xml'
         end
         
end


Then /^it should contain (no|some) pim best practices violations$/ do |amount|

  case amount

  when 'no'
    last_response.should have_selector('h2', :content => "Document conforms to PREMIS in METS best practice")

  when 'some'
    last_response.should have_selector('h2', :content => "Document does not conform to PREMIS in METS best practice")
    last_response.should have_selector('ul li code')
  end
end
