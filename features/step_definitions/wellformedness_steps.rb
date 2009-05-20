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
    tag.text.should == 'Validation Results'
  end
end

Then /^it should contain (no|some) formedness errors$/ do |quantity|

  last_response.should have_selector('h2') do |tag|
    tag.text.should == 'Formedness'
  end

  # TODO errors after formedness
end
