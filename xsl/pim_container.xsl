<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:premis="info:lc/xmlns/premis-v2"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                version="1.0">
  
  <xsl:import href="xsl/pim_base.xsl"/>
  
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:processing-instruction name="xml-stylesheet">href="/pim2html.xsl" type="text/xsl"</xsl:processing-instruction>
    
    <mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink"
          xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/version18/mets.xsd 
          info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/premis.xsd">
      
      <amdSec ID='PREMIS_AMD'>
        <xsl:apply-templates select="premis:premis"/>
      </amdSec>

      <fileSec>
        <fileGrp ADMID='PREMIS_AMD'>
          <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='file']" mode="file"/>
        </fileGrp>
      </fileSec>

      <xsl:if test="premis:premis/premis:object[@xsi:type='representation' and premis:relationship/premis:relationshipType='structural']">
      
      <!-- structural representations -->
      <structMap LABEL="representation map">
        <div>
          <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='representation' and 
                                       premis:relationship/premis:relationshipType='structural']"/>
        </div>
      </structMap>
      
      </xsl:if>
      
      <!-- flat structMap with all files -->
      <structMap LABEL="flat">
        <div>
          <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='file']" mode="filep"/>
        </div>
      </structMap>

    </mets>
  </xsl:template>

  <!-- copy the entire premis container into a digiprovMD -->
  <xsl:template match="premis:premis">
    <digiprovMD xmlns="http://www.loc.gov/METS/">
      <mdWrap MDTYPE="PREMIS">
        <xmlData>
          <xsl:copy-of select="."/>
        </xmlData>
      </mdWrap>
    </digiprovMD>
  </xsl:template>

</xsl:stylesheet>
