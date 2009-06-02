require 'nokogiri'

XMLNS = {
       'mets' => 'http://www.loc.gov/METS/',
       'premis' => 'info:lc/xmlns/premis-v2'
        }

Given /^a PREMIS document$/ do
  @doc = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<premis xmlns="info:lc/xmlns/premis-v2" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
     
  <!-- Representation object -->
  <object xsi:type="representation">
    <objectIdentifier>
      <objectIdentifierType>local</objectIdentifierType>
      <objectIdentifierValue>E20090127_AAAAAA/representation/1</objectIdentifierValue>
    </objectIdentifier>
  </object>
  
  <!-- File objects -->
  <object xsi:type="file">
    <objectIdentifier>
      <objectIdentifierType>local</objectIdentifierType>
      <objectIdentifierValue>F20090127_AAAAAA</objectIdentifierValue>
    </objectIdentifier>
    <objectCharacteristics>
      <compositionLevel>0</compositionLevel>
      <fixity>
        <messageDigestAlgorithm>SHA-1</messageDigestAlgorithm>
        <messageDigest>34bcb73f6ea7c852989b5dd108060c1bda989ddb</messageDigest>
      </fixity>
      <size>49236</size>
      <format>
        <formatDesignation>
	      <formatName>jpeg</formatName>
        </formatDesignation>
      </format>
    </objectCharacteristics>
    <storage>
      <contentLocation>
        <contentLocationType>EXT3</contentLocationType>
        <contentLocationValue>foo/bar/baz.jpg</contentLocationValue>
      </contentLocation>
    </storage>
  </object>
  
  <object xsi:type="file">
    <objectIdentifier>
      <objectIdentifierType>URI</objectIdentifierType>
      <objectIdentifierValue>F20090127_AAAAAC</objectIdentifierValue>
    </objectIdentifier>
    <objectCharacteristics>
      <compositionLevel>0</compositionLevel>
      <format>
        <formatDesignation>
	      <formatName>xml</formatName>
          <formatVersion>1.0</formatVersion>
        </formatDesignation>
      </format>
    </objectCharacteristics>
  </object>  

  <event>
    <eventIdentifier>
      <eventIdentifierType>local</eventIdentifierType>
      <eventIdentifierValue>E20090127_AAAAAA/event/488374</eventIdentifierValue>
    </eventIdentifier>
    <eventType>virus check</eventType>
    <eventDateTime>2009-01-27T14:32:12-05:00</eventDateTime>
 
    <eventDetail>Checked for virus during DataFile creation</eventDetail>
    <eventOutcomeInformation>
      <eventOutcome>SUCCESS</eventOutcome>
      <eventOutcomeDetail>
        <eventOutcomeDetailNote/>
      </eventOutcomeDetail>
    </eventOutcomeInformation>

    <linkingObjectIdentifier>
      <linkingObjectIdentifierType>local</linkingObjectIdentifierType>
      <linkingObjectIdentifierValue>F20090127_AAAAAA</linkingObjectIdentifierValue>
    </linkingObjectIdentifier>

    <linkingObjectIdentifier>
      <linkingObjectIdentifierType>local</linkingObjectIdentifierType>
      <linkingObjectIdentifierValue>E20090127_AAAAAA/representation/1</linkingObjectIdentifierValue>
        <linkingObjectRole>associated representation</linkingObjectRole>
    </linkingObjectIdentifier>
  </event>

  <event>
    <eventIdentifier>
      <eventIdentifierType>local</eventIdentifierType>
      <eventIdentifierValue>E20090127_AAAAAA/event/488373</eventIdentifierValue>
    </eventIdentifier>

 
    <eventType>ingest</eventType>
 
    <eventDateTime>2009-01-27T14:32:11-05:00</eventDateTime>
 
    <eventDetail>Package ingested by FDA</eventDetail>
 
    <eventOutcomeInformation>
      <eventOutcome>SUCCESS</eventOutcome>
      <eventOutcomeDetail>
        <eventOutcomeDetailNote/>
      </eventOutcomeDetail>
    </eventOutcomeInformation>
    <linkingAgentIdentifier>
      <linkingAgentIdentifierType>local</linkingAgentIdentifierType>
      <linkingAgentIdentifierValue>FDA</linkingAgentIdentifierValue>
    </linkingAgentIdentifier>

    <linkingObjectIdentifier>
      <linkingObjectIdentifierType>local</linkingObjectIdentifierType>
      <linkingObjectIdentifierValue>E20090127_AAAAAA/representation/1</linkingObjectIdentifierValue>
    </linkingObjectIdentifier>
  </event>

  <agent>
    <agentIdentifier>
      <agentIdentifierType>local</agentIdentifierType>
      <agentIdentifierValue>FDA</agentIdentifierValue>
    </agentIdentifier>
    <agentName>FDA</agentName>
    <agentType>organization</agentType>
  </agent>



</premis>
XML
end

Given /^I want a premis container$/ do
  @embedding = "container"
end

When /^I convert it$/ do
  post '/convert', { :document => @doc, :convert => "p2pim", 
                     :embed_as => @embedding }
end

Then /^a METS document should be returned$/ do
  pending
  last_response.status.should == 200
  last_response.body.should contain('</mets>')
end

Then /^it should have a single PREMIS container within a METS digiprovMD section$/ do
  pending
  mets_doc = last_response.body.match(/\<mets.*\<\/mets\>/m)
  mets_doc.should_not be_nil
  
  mets = Nokogiri::XML::Document.parse(mets_doc[0])
  mets.should have_xpath('//mets:digiprovMD//premis:premis', XMLNS)
  mets.xpath('//premis:premis', XMLNS).length.should == 1
  
end
