Given /^I submit an? (well|ill)-formed document$/ do |state|
  @doc = case state
         when 'well'
           "<root><element>Text Node</element></root>"
         when 'ill'
           "<root><element>Text Node</element>"
         end
end

When /^I press validate$/ do
  post '/validate', :document => @doc 
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

    last_response.body.should have_selector('h2') do |tag|
      tag.should contain('document is well-formed')
    end

  when 'some'

    last_response.body.should have_selector('h2') do |tag|
      tag.should contain('document is ill-formed')
    end
    
    last_response.body.should have_selector('code') do |tag|
      tag.should contain("Fatal error:")
    end
    
  end

end
