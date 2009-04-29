Given /^I enter a url to a PiM document$/ do
  visit "/"
  fill_in "Address:", :with => 'http://foo/bar/baz/TODO'
end

Given /^I press validate$/ do
  click_bottun "Validate"
end

Then /^a result document should be returned$/ do
  assert_contain "Validation Results"
end

Given /^I select to upload a PiM document file$/ do
  pending
end

Given /^I enter PiM XML in the text area$/ do
  pending
end
