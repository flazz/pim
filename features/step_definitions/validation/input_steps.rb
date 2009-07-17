require 'cgi'

Given /^I navigate to the validation form page$/ do
  pending 'webrat methods not quite working with this setup'
  visit '/'
  click_link 'Validate PREMIS in METS'
end

Given /^I enter a url to a PiM document$/ do
  pending 'webrat methods not quite working with this setup'
  
  fill_in "Address:", :with => 'http://wiki.fcla.edu:8000/TIPR/uploads/3/fda_tipr.xml'
end

Given /^I select to upload a PiM document file$/ do
  pending 'webrat methods not quite working with this setup'
  attach_file 'File:', fixture_file('pim_container.xml'), 'text/xml'
end

Given /^I enter PiM XML in the text area$/ do
  pending 'webrat methods not quite working with this setup'
  fill_in 'Enter XML Document:', :with => fixture_data('simple_premis.xml')
end

When /^I validate (.*)$/ do |type|
  pending 'webrat methods not quite working with this setup'
  click_button 'Validate'
end
