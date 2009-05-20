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
    tag.text.should =~ /Validation Results/i
  end
end

Then /^it should contain (no|some) formedness errors$/ do |quantity|

  case quantity
  when 'no'

    last_response.body.should have_selector('p') do |tag|
      tag.text.should == 'document is well-formed'
    end

  when 'some'
    
    last_response.body.should have_selector('p') do |tag|
      tag.text.should == 'document is ill-formed'
    end

  end

end