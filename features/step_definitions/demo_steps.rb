Given /^I navigate to the description form page$/ do
  pending 'not really integrated into the description service'
  visit '/'
  click_link 'Describe'
end

Given /^I select to upload the demo pdf$/ do
  uploadfile_field = field_with_id 'uploadfile'

  within('#input-file') do
    fill_in field_with_id('id_type'), :with => 'URI'
    fill_in field_with_id('id_value'), :with => 'Thesis'
    fill_in field_with_id('ieid_type'), :with => 'URI'
    fill_in field_with_id('ieid_value'), :with => 'FCLA Thesis SIP'
    attach_file uploadfile_field, fixture_file('demo.pdf'), 'application/pdf'
  end

end

When /^I run the demo$/ do
  within('#input-file') { click_button 'Describe' }
  last_response.should be_ok
  premis_description_xml = last_response.body

  visit '/'
  click_link 'Convert'

  within('#input-direct') do
    fill_in field_with_id('xxx'), :with => premis_description_xml
    click_button 'Convert'
  end

  last_response.should be_ok
  pim_description_xml = last_response.body

  visit '/'
  click_link 'Validate'

  within('#input-direct') do
    fill_in field_with_id('xxx'), :with => pim_description_xml
    click_button 'Convert'
  end

  last_response.should be_ok
  pim_description_xml = last_response.body
end

Then /^I should end up with a conforming METS doc$/ do
  "Document conforms to PREMIS in METS best practice"
end
