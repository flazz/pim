Given /^I submit an? (well|ill)-formed document$/ do |state|

  @doc = case state
         when 'well'
           <<WELL
<root><element>Text Node</element></root>
WELL
         when 'ill'
           <<ILL
<root><element>Text Node</element></root>
ILL
         end
  
end

When /^I press validate$/ do
  post 'validate', :document => @doc
end

Then /^a result document should be returned$/ do
  pending
end

Then /^it should contain (no|some) formedness errors$/ do |amount|
  
  case amount
  when 'no'
    last_request.should_not have_xpath ''
  when 'some'
    last_request.should_not have_xpath ''
  end

end
