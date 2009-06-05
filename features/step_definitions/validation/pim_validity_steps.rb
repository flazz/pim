Given /^I submit a\(n\) (valid|invalid) PiM document$/ do |state|

  @doc = case state
         when 'valid'
           <<XML
<?xml version="1.0" encoding="UTF-8"?>
<mets xmlns="http://www.loc.gov/METS/"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/version17/mets.xsd
                          info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/draft-schemas-2-0/premis-v2-0.xsd
                          http://www.loc.gov/mix/v10 http://www.loc.gov/standards/mix/mix10/mix10.xsd">
  <amdSec>
    <techMD ID="object-1">
      <mdWrap MDTYPE="PREMIS">
        <xmlData>

          <object xsi:type='file' xmlns="info:lc/xmlns/premis-v2">
            <objectIdentifier>
              <objectIdentifierType>URI</objectIdentifierType>
              <objectIdentifierValue>daitss://archive.fcla.edu/p926/f0</objectIdentifierValue>
            </objectIdentifier>
            <objectCharacteristics>
              <compositionLevel>0</compositionLevel>
              <fixity>
                <messageDigestAlgorithm>MD5</messageDigestAlgorithm>
                <messageDigest>2de9ef79df730f93e40819625cf7bcb2</messageDigest>
              </fixity>
              <size>3001452</size>
              <format>
                <formatDesignation>
                  <formatName>TIFF</formatName>
                  <formatVersion>4.0</formatVersion>
                </formatDesignation>
                <formatRegistry>
                  <formatRegistryName>http://www.nationalarchives.gov.uk/pronom</formatRegistryName>
                  <formatRegistryKey>fmt/8</formatRegistryKey>
                </formatRegistry>
              </format>
              <objectCharacteristicsExtension>
                <BasicImageInformation xmlns="http://www.loc.gov/mix/v10" >
                  <BasicImageCharacteristics>
                    <imageWidth>1000</imageWidth>
                    <imageHeight>1000</imageHeight>
                    <ByteOrder>little-endian</ByteOrder>
                    <Compression>
                      <CompressionScheme>1</CompressionScheme>
                    </Compression>
                    <PhotometricInterpretation>
                      <ColorSpace>2</ColorSpace>
                      <ReferenceBlackWhite>0.0 255.0 0.0 255.0 0.0 255.0</ReferenceBlackWhite>
                    </PhotometricInterpretation>
                    <PlanarConfiguration>1</PlanarConfiguration>
                  </BasicImageCharacteristics>
                  <ImageCaptureMetadata>
                    <orientation>1</orientation>
                  </ImageCaptureMetadata>
                </BasicImageInformation>
              </objectCharacteristicsExtension>
            </objectCharacteristics>
          </object>

        </xmlData>
      </mdWrap>
    </techMD>
  </amdSec>

  <fileSec>
    <fileGrp>
      <file ID="file-1" ADMID="object-1"/>
    </fileGrp>
  </fileSec>

  <structMap ID='structmap-0'>
    <div>
      <fptr FILEID="file-1"/>
    </div>
  </structMap>

</mets>
XML
         when 'invalid'
           <<XML
<?xml version="1.0" encoding="UTF-8"?>
<mets xmlns="http://www.loc.gov/METS/"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/version17/mets.xsd
                          info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/draft-schemas-2-0/premis-v2-0.xsd
                          http://www.loc.gov/mix/v10 http://www.loc.gov/standards/mix/mix10/mix10.xsd">
  <amdSec>
    <digiprovMD ID="object-1">
      <mdWrap MDTYPE="PREMIS">
        <xmlData>

          <object xsi:type='file' xmlns="info:lc/xmlns/premis-v2">
            <objectIdentifier>
              <objectIdentifierType>URI</objectIdentifierType>
              <objectIdentifierValue>daitss://archive.fcla.edu/p926/f0</objectIdentifierValue>
            </objectIdentifier>
            <objectCharacteristics>
              <compositionLevel>0</compositionLevel>
              <fixity>
                <messageDigestAlgorithm>MD5</messageDigestAlgorithm>
                <messageDigest>2de9ef79df730f93e40819625cf7bcb2</messageDigest>
              </fixity>
              <size>3001452</size>
              <format>
                <formatDesignation>
                  <formatName>TIFF</formatName>
                  <formatVersion>4.0</formatVersion>
                </formatDesignation>
                <formatRegistry>
                  <formatRegistryName>http://www.nationalarchives.gov.uk/pronom</formatRegistryName>
                  <formatRegistryKey>fmt/8</formatRegistryKey>
                </formatRegistry>
              </format>
              <objectCharacteristicsExtension>
                <BasicImageInformation xmlns="http://www.loc.gov/mix/v10" >
                  <BasicImageCharacteristics>
                    <imageWidth>1000</imageWidth>
                    <imageHeight>1000</imageHeight>
                    <ByteOrder>little-endian</ByteOrder>
                    <Compression>
                      <CompressionScheme>1</CompressionScheme>
                    </Compression>
                    <PhotometricInterpretation>
                      <ColorSpace>2</ColorSpace>
                      <ReferenceBlackWhite>0.0 255.0 0.0 255.0 0.0 255.0</ReferenceBlackWhite>
                    </PhotometricInterpretation>
                    <PlanarConfiguration>1</PlanarConfiguration>
                  </BasicImageCharacteristics>
                  <ImageCaptureMetadata>
                    <orientation>1</orientation>
                  </ImageCaptureMetadata>
                </BasicImageInformation>
              </objectCharacteristicsExtension>
            </objectCharacteristics>
          </object>

        </xmlData>
      </mdWrap>
    </digiprovMD>
  </amdSec>

  <fileSec>
    <fileGrp>
      <file ID="file-1" ADMID="object-1"/>
    </fileGrp>
  </fileSec>

  <structMap ID='structmap-0'>
    <div>
      <fptr FILEID="file-1"/>
    </div>
  </structMap>

</mets>
XML
         end

end


Then /^it should contain (no|some) pim best practices violations$/ do |amount|

  case amount

  when 'no'
    last_response.should have_selector('h2') do |tag|
      tag.text.should contain("document conforms to PREMIS in METS best practice")
    end

  when 'some'
    last_response.should have_selector('h2') do |tag|
      tag.text.should contain("document violates PREMIS in METS best practice")
    end

    last_response.body.should have_selector('ul li') do |tag|
      tag.text.should contain('techMD')
    end

  end
end
