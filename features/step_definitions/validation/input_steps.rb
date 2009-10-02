require 'cgi'

Given /^I navigate to the validation form page$/ do
  visit '/'
  click_link 'Validate'
end

Given /^I enter a url to a PiM document$/ do
  @input_method = 'uri'
  uri_field = field_with_id 'uri'
  fill_in uri_field, :with => 'http://wiki.fcla.edu:8000/TIPR/uploads/3/fda_tipr.xml'
end

Given /^I select to upload a PiM document file$/ do
  @input_method = 'file'
  uploadfile_field = field_with_id 'uploadfile'
  attach_file uploadfile_field, fixture_file('pim_container.xml'), 'text/xml'
end

Given /^I enter PiM XML in the text area$/ do
  @input_method = 'direct'
  directinput_field = field_with_id 'directinput'
  fill_in directinput_field, :with => fixture_data('simple_premis.xml')
end

When /^I validate (.*)$/ do |type|
  div = case @input_method
        when 'uri'
          '#input-uri'
        when 'file'
          '#input-file'
        when 'direct'
          '#input-direct'
        end
        
  within(div) { click_button 'Validate' }
end
