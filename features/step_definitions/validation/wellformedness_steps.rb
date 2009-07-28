Given /^I submit an? (well|ill)-formed document$/ do |state|
  @doc = case state
         when 'well'
           fixture_data 'pim_container.xml'
         when 'ill'
           fixture_data 'not_well_formed.xml'
         end
end

When /^I press validate$/ do
  post '/validate/results', :document => @doc 
end

Then /^a result document should be returned$/ do
  last_response.status.should == 200

  last_response.should have_selector('h1') do |tag|
    tag.text.should =~ /Results/
  end
  
end

Then /^it should contain (no|some) formedness errors$/ do |quantity|

  case quantity
  when 'no'
    last_response.body.should have_selector('h2', :content => 'Document is well-formed')
    
  when 'some'
    last_response.body.should have_selector('h2', :content => 'Document is not well-formed:')
    last_response.body.should have_selector('code')
    
  end

end
