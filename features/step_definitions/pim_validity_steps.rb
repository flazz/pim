Given /^I submit a\(n\) (valid|invalid) PiM document$/ do |type|

  # Choose the correct document
  fp = File.join(File.dirname(__FILE__), '..', '..', 'spec/fixtures/pim')
  
  file = type == 'valid' ? "case1.xml" : "case4.xml"
  doc = File.join(fp, file)
  @doc = Rack::Test::UploadedFile.new(doc)

end


Then /^it should contain (no|some) pim best practices violations$/ do |amount|

  last_response.should have_selector('h2') do |tag|
    tag.text.should =~ /PiM Validity/
  end
  
  # Check for errors
  case amount
  
  when 'no'
    last_response.should have_selector('h3') do |tag|
      tag.text.should =~ /Document is PREMIS-in-METS compliant/
    end
  
  else
    
    last_response.should have_selector('h3') do |tag|
      tag.text.should =~ /Document is not PREMIS-in-METS compliant/
    end
    
    last_response.should match_xpath('//table/tr') do |tags|
      tags.length.should > 1
    end
    
  end
end
