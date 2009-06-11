<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:premis="info:lc/xmlns/premis-v2" 
	xmlns="http://www.loc.gov/METS/" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0">
	
  <xsl:import href="xsl/pim_base.xsl"/>

  <xsl:output method="xml" indent="yes"/>
	
  <xsl:template match="/">

    <xsl:processing-instruction name="xml-stylesheet">href="/pim2html.xsl" type="text/xsl"</xsl:processing-instruction>  
  
    <mets xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/version18/mets.xsd 
                              info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/premis.xsd 
                              http://www.loc.gov/mix/v10 http://www.loc.gov/standards/mix/mix10/mix10.xsd">
      <amdSec>
        <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='file']" mode="bucket"/>
        <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='representation']" mode="bucket"/>
        <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='bitstream']" mode="bucket"/>
        <xsl:apply-templates select="premis:premis/premis:rights"/>
        <xsl:apply-templates select="premis:premis/premis:event"/>
        <xsl:apply-templates select="premis:premis/premis:agent"/>
      </amdSec>
      <fileSec>
        <fileGrp>
          <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='file']" mode="file">
            <xsl:with-param name="buckets" select="true()"/>
          </xsl:apply-templates>
        </fileGrp>
      </fileSec>
      <xsl:if test="premis:premis/premis:object[@xsi:type='representation' and premis:relationship/premis:relationshipType='structural']">

      <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='representation' and 
                                   premis:relationship/premis:relationshipType='structural']"/>
      </xsl:if>
      
      
      <xsl:call-template name="orphaned-file-map"/>
      
    </mets>
  </xsl:template>
	
  <!-- techMD for premis files -->
  <xsl:template match="premis:premis/premis:object[@xsi:type='file']" mode="bucket">
    <xsl:call-template name="tech-bucket">
      <xsl:with-param name="contents">
        <xsl:copy-of select="."/>
      </xsl:with-param>
      <xsl:with-param name="identifier">
        <xsl:text>object-</xsl:text><xsl:value-of select="position()" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- techMD for premis representations -->
  <xsl:template match="premis:premis/premis:object[@xsi:type='representation']" mode="bucket">
    <xsl:call-template name="tech-bucket">
      <xsl:with-param name="contents">
        <xsl:copy-of select="."/>
      </xsl:with-param>
      <xsl:with-param name="identifier">
        <xsl:text>representation-</xsl:text><xsl:value-of select="position()" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- techMD for premis bitstreams -->
  <xsl:template match="premis:premis/premis:object[@xsi:type='bitstream']" mode="bucket">
    <xsl:call-template name="tech-bucket">
      <xsl:with-param name="contents">
        <xsl:copy-of select="."/>
      </xsl:with-param>
      <xsl:with-param name="identifier">
        <xsl:text>bitstream-</xsl:text><xsl:value-of select="position()" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <!-- rightsMD for premis rights -->
  <xsl:template match="premis:premis/premis:rights">
    <xsl:call-template name="rights-bucket">
      <xsl:with-param name="contents">
        <xsl:copy-of select="."/>
      </xsl:with-param>
      <xsl:with-param name="identifier">
        <xsl:text>rights-</xsl:text><xsl:value-of select="position()" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

	
  <!-- event digiprovMD -->
  <xsl:template match="premis:premis/premis:event">
    <xsl:call-template name="digiprov-bucket">
    
      <xsl:with-param name="contents">
        <xsl:copy-of select="."/>
      </xsl:with-param>
      
      <xsl:with-param name="identifier">
        <xsl:text>event-</xsl:text><xsl:value-of select="position()" />
      </xsl:with-param>
      
      <xsl:with-param name="relatedObjects">
        
        <!-- objects of this event -->
          <xsl:variable name="oType">
            <xsl:value-of select="premis:linkingObjectIdentifier/premis:linkingObjectIdentifierType"/>
          </xsl:variable>
          <xsl:variable name="oValue">
            <xsl:value-of select="premis:linkingObjectIdentifier/premis:linkingObjectIdentifierValue"/>
          </xsl:variable>
          <xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
            <xsl:if test="premis:objectIdentifier/premis:objectIdentifierType=$oType and premis:objectIdentifier/premis:objectIdentifierValue=$oValue">
              <xsl:text> </xsl:text>
              <xsl:text>object-</xsl:text><xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>
          
          <!-- objects with relationships that match this event -->
          <xsl:variable name="eType">
            <xsl:value-of select="premis:eventIdentifier/premis:eventIdentifierType"/>
          </xsl:variable>
          <xsl:variable name="eValue">
            <xsl:value-of select="premis:eventIdentifier/premis:eventIdentifierValue"/>
          </xsl:variable>
          <xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
            <xsl:if test="premis:relationship/premis:relatedEventIdentification/premis:relatedEventIdentifierType=$eType and 
                          premis:relationship/premis:relatedEventIdentification/premis:relatedEventIdentifierValue=$eValue">
              <xsl:text>object-</xsl:text><xsl:value-of select="position()" />
              <xsl:variable name="oRelType">
                <xsl:value-of select="premis:relationship/premis:relatedObjectIdentification/premis:relatedObjectIdentifierType"/>
              </xsl:variable>
              <xsl:variable name="oRelValue">
                <xsl:value-of select="premis:relationship/premis:relatedObjectIdentification/premis:relatedObjectIdentifierValue"/>
              </xsl:variable>
              
              <xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
                <xsl:if test="premis:objectIdentifier/premis:objectIdentifierType=$oRelType and premis:objectIdentifier/premis:objectIdentifierValue=$oRelValue">
                  <xsl:text> </xsl:text>
                  <xsl:text>object-</xsl:text><xsl:value-of select="position()" />
                </xsl:if>
              </xsl:for-each>
            </xsl:if>
          </xsl:for-each>
        </xsl:with-param>
        
        <!-- agents related to this event -->
        <xsl:with-param name="relatedAgents">
          <xsl:variable name="aType">
            <xsl:value-of select="premis:linkingAgentIdentifier/premis:linkingAgentIdentifierType"/>
          </xsl:variable>
          <xsl:variable name="aValue">
            <xsl:value-of select="premis:linkingAgentIdentifier/premis:linkingAgentIdentifierValue"/>
          </xsl:variable>
          
          <xsl:for-each select="/premis:premis/premis:agent">
            <xsl:if test="premis:agentIdentifier/premis:agentIdentifierType=$aType and premis:agentIdentifier/premis:agentIdentifierValue=$aValue">
              <xsl:text>agent-</xsl:text><xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>
        </xsl:with-param>
    </xsl:call-template>

  </xsl:template>
	
  <!-- agent digiprovMD -->
  <xsl:template match="premis:premis/premis:agent">
    <xsl:call-template name="digiprov-bucket">
      <xsl:with-param name="contents">
        <xsl:copy-of select="."/>
      </xsl:with-param>
      <xsl:with-param name="identifier">
        <xsl:text>agent-</xsl:text><xsl:value-of select="position()" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
	
  <!-- mets digiprovMD bucket -->
  <xsl:template name="digiprov-bucket">
    <xsl:param name="contents"/>
    <xsl:param name="identifier"/>
    <xsl:param name="relatedObjects"/>
    <xsl:param name="relatedAgents"/>
    <digiprovMD>
      <xsl:attribute name="ID">
        <xsl:value-of select="$identifier"/>
      </xsl:attribute>
      <xsl:if test="string-length(concat($relatedAgents, $relatedObjects)) != 0">
        <xsl:attribute name="ADMID">
          <xsl:value-of select="concat($relatedAgents, ' ', $relatedObjects)"/>
        </xsl:attribute>
      </xsl:if>
        
      <xsl:call-template name="mdwrap-xmldata-bucket">
        <xsl:with-param name="contents">
          <xsl:copy-of select="$contents"/>
        </xsl:with-param>
        
        <xsl:with-param name="mdtype">PREMIS</xsl:with-param>
      </xsl:call-template>
    </digiprovMD>
  </xsl:template>
	
  <!-- mets techMD bucket -->
  <xsl:template name="tech-bucket">
    <xsl:param name="contents"/>
    <xsl:param name="identifier"/>
    
    <techMD>
      <xsl:attribute name="ID">
        <xsl:value-of select="$identifier"/>
      </xsl:attribute>
      <xsl:call-template name="mdwrap-xmldata-bucket">
        <xsl:with-param name="contents">
          <xsl:copy-of select="$contents"/>
        </xsl:with-param>
        <xsl:with-param name="mdtype">PREMIS</xsl:with-param>
      </xsl:call-template>
    </techMD>
  </xsl:template>

  <!-- mets rightsMD bucket -->
  <xsl:template name="rights-bucket">
    <xsl:param name="contents"/>
    <xsl:param name="identifier"/>
    
    <rightsMD>
      <xsl:attribute name="ID">
        <xsl:value-of select="$identifier"/>
      </xsl:attribute>
      <xsl:call-template name="mdwrap-xmldata-bucket">
        <xsl:with-param name="contents">
          <xsl:copy-of select="$contents"/>
        </xsl:with-param>
        <xsl:with-param name="mdtype">PREMIS</xsl:with-param>
      </xsl:call-template>
    </rightsMD>
  </xsl:template>

	
</xsl:stylesheet>
