<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:premis="info:lc/xmlns/premis-v2" 
	xmlns="http://www.loc.gov/METS/" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0">
	
  <xsl:import href="xsl/pim_base.xsl"/>

  <xsl:output method="xml" indent="yes"/>
	
  <xsl:template match="/">

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
      <xsl:if test="premis:premis/premis:object[@xsi:type='representation' and 
                    normalize-space(premis:relationship/premis:relationshipType)='structural']">

      <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='representation']"/>
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
      
      <xsl:with-param name="relatedAgents">
        <!-- is this object linked to by a rights statement? -->
        <xsl:variable name="aType">
          <xsl:value-of select="normalize-space(premis:rightsStatement//premis:linkingAgentIdentifierType)"/>
        </xsl:variable>
        <xsl:variable name="aValue">
          <xsl:value-of select="normalize-space(premis:rightsStatement//premis:linkingAgentIdentifierValue)"/>
        </xsl:variable>
        <xsl:for-each select="/premis:premis/premis:agent">
          <xsl:if test="normalize-space(premis:agentIdentifier/premis:agentIdentifierType)=$aType and 
                        normalize-space(premis:agentIdentifier/premis:agentIdentifierValue)=$aValue">
            <xsl:text> </xsl:text>
            <xsl:text>agent-</xsl:text><xsl:value-of select="position()" />
          </xsl:if>
        </xsl:for-each>
      
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
        <xsl:for-each select="premis:linkingObjectIdentifier">
          <xsl:variable name="oType">
            <xsl:value-of select="normalize-space(premis:linkingObjectIdentifierType)"/>
          </xsl:variable>
          <xsl:variable name="oValue">
            <xsl:value-of select="normalize-space(premis:linkingObjectIdentifierValue)"/>
          </xsl:variable>
          <xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
            <xsl:if test="normalize-space(premis:objectIdentifier/premis:objectIdentifierType)=$oType and 
                          normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)=$oValue">
              <xsl:text> </xsl:text>
              <xsl:text>object-</xsl:text><xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>
          <xsl:for-each select="/premis:premis/premis:object[@xsi:type='representation']">
            <xsl:if test="normalize-space(premis:objectIdentifier/premis:objectIdentifierType)=$oType and 
                          normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)=$oValue">
              <xsl:text> </xsl:text>
              <xsl:text>representation-</xsl:text><xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
          
          <!-- file objects with relationships that match this event -->
          <xsl:variable name="eType">
            <xsl:value-of select="normalize-space(premis:eventIdentifier/premis:eventIdentifierType)"/>
          </xsl:variable>
          <xsl:variable name="eValue">
            <xsl:value-of select="normalize-space(premis:eventIdentifier/premis:eventIdentifierValue)"/>
          </xsl:variable>
          <xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
            <xsl:if test="normalize-space(premis:relationship//premis:relatedEventIdentifierType)=$eType and 
                          normalize-space(premis:relationship//premis:relatedEventIdentifierValue)=$eValue">
              <xsl:text> </xsl:text>
              <xsl:text>object-</xsl:text><xsl:value-of select="position()" />
              
              <xsl:call-template name="relationship_linking">
                <xsl:with-param name="otype">
                  <xsl:value-of select="normalize-space(premis:relationship//premis:relatedObjectIdentifierType)"/>
                </xsl:with-param>
                <xsl:with-param name="ovalue">
                  <xsl:value-of select="normalize-space(premis:relationship//premis:relatedObjectIdentifierValue)"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
            
            <!-- file objects with linkingEventIdentifiers -->
            <xsl:if test="normalize-space(premis:linkingEventIdentifier/premis:linkingEventIdentifierType)=$eType and 
                          normalize-space(premis:linkingEventIdentifier/premis:linkingEventIdentifierValue)=$eValue">
              <xsl:text> </xsl:text>
              <xsl:text>object-</xsl:text><xsl:value-of select="position()" />
            </xsl:if>

          </xsl:for-each>

          <!-- representaiton objects with relationships that match this event -->
          <xsl:for-each select="/premis:premis/premis:object[@xsi:type='representation']">
            <xsl:if test="normalize-space(premis:relationship//premis:relatedEventIdentifierType)=$eType and 
                          normalize-space(premis:relationship//premis:relatedEventIdentifierValue)=$eValue">
              <xsl:text> </xsl:text>
              <xsl:text>representation-</xsl:text><xsl:value-of select="position()" />
              <xsl:call-template name="relationship_linking">
                <xsl:with-param name="otype">
                  <xsl:value-of select="normalize-space(premis:relationship//premis:relatedObjectIdentifierType)"/>
                </xsl:with-param>
                <xsl:with-param name="ovalue">
                  <xsl:value-of select="normalize-space(premis:relationship//premis:relatedObjectIdentifierValue)"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>

            <!-- representation objects with matching linkingEventIdentifiers  -->
            <xsl:if test="normalize-space(premis:linkingEventIdentifier/premis:linkingEventIdentifierType)=$eType and 
                          normalize-space(premis:linkingEventIdentifier/premis:linkingEventIdentifierValue)=$eValue">
              <xsl:text> </xsl:text>
              <xsl:text>representation-</xsl:text><xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>

          <!-- bitstream objects with relationships that match this event -->
          <xsl:for-each select="/premis:premis/premis:object[@xsi:type='bitstream']">
            <xsl:if test="normalize-space(premis:relationship//premis:relatedEventIdentifierType)=$eType and 
                          normalize-space(premis:relationship//premis:relatedEventIdentifierValue)=$eValue">
              <xsl:text> </xsl:text>
              <xsl:text>bitstream-</xsl:text><xsl:value-of select="position()" />
              <xsl:call-template name="relationship_linking">
                <xsl:with-param name="otype">
                  <xsl:value-of select="normalize-space(premis:relationship//premis:relatedObjectIdentifierType)"/>
                </xsl:with-param>
                <xsl:with-param name="ovalue">
                  <xsl:value-of select="normalize-space(premis:relationship//premis:relatedObjectIdentifierValue)"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>

            <!-- bitstream objects with matching linkingEventIdentifiers  -->
            <xsl:if test="normalize-space(premis:linkingEventIdentifier/premis:linkingEventIdentifierType)=$eType and 
                          normalize-space(premis:linkingEventIdentifier/premis:linkingEventIdentifierValue)=$eValue">
              <xsl:text> </xsl:text>
              <xsl:text>bitstream-</xsl:text><xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>

      </xsl:with-param>
        
      <!-- agents related to this event -->
      <xsl:with-param name="relatedAgents">
        <xsl:variable name="aType">
          <xsl:value-of select="normalize-space(premis:linkingAgentIdentifier/premis:linkingAgentIdentifierType)"/>
        </xsl:variable>
        <xsl:variable name="aValue">
          <xsl:value-of select="normalize-space(premis:linkingAgentIdentifier/premis:linkingAgentIdentifierValue)"/>
        </xsl:variable>
          
        <xsl:for-each select="/premis:premis/premis:agent">
          <xsl:if test="normalize-space(premis:agentIdentifier/premis:agentIdentifierType)=$aType and 
                        normalize-space(premis:agentIdentifier/premis:agentIdentifierValue)=$aValue">
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
      <xsl:if test="string-length(normalize-space(concat($relatedAgents, $relatedObjects))) != 0">
        <xsl:variable name="agents">
          <xsl:value-of select="normalize-space($relatedAgents)"/>
        </xsl:variable>
        <xsl:variable name="objects">
          <xsl:value-of select='normalize-space($relatedObjects)'/>
        </xsl:variable>
        <xsl:attribute name="ADMID">
          <xsl:value-of select="concat($agents, ' ', $objects)"/>
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

      <xsl:variable name="relatedRights">
        
        <!-- rights related to this object -->
        <xsl:for-each select="premis:linkingRightsStatementIdentifier">
          <xsl:variable name="rType">
            <xsl:value-of select="normalize-space(premis:linkingRightsStatementIdentifierType)"/>
          </xsl:variable>
          <xsl:variable name="rValue">
            <xsl:value-of select="normalize-space(premis:linkingRightsStatementIdentifierValue)"/>
          </xsl:variable>
          <xsl:for-each select="/premis:premis/premis:rights">
            <xsl:if test="normalize-space(premis:rightsStatement//premis:rightsStatementIdentifierType)=$rType and 
                          normalize-space(premis:rightsStatement//premis:rightsStatementIdentifierValue)=$rValue">
              <xsl:text> </xsl:text>
              <xsl:text>rights-</xsl:text><xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
        
        <!-- is this object linked to by a rights statement? -->
        <xsl:variable name="oType">
          <xsl:value-of select="normalize-space(premis:objectIdentifier/premis:objectIdentifierType)"/>
        </xsl:variable>
        <xsl:variable name="oValue">
          <xsl:value-of select="normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)"/>
        </xsl:variable>
        <xsl:for-each select="/premis:premis/premis:rights">
          <xsl:if test="normalize-space(premis:rightsStatement//premis:linkingObjectIdentifierType)=$oType and 
                        normalize-space(premis:rightsStatement//premis:linkingObjectIdentifierValue)=$oValue">
            <xsl:text> </xsl:text>
            <xsl:text>rights-</xsl:text><xsl:value-of select="position()" />
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      
      <xsl:if test="normalize-space($relatedRights) != ''">
        <xsl:variable name="rights">
          <xsl:value-of select='normalize-space($relatedRights)'/>
        </xsl:variable>
        <xsl:attribute name="ADMID">
          <xsl:value-of select="$rights"/>
        </xsl:attribute>
      </xsl:if>

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
    <xsl:param name="relatedAgents"/>
    
    <rightsMD>
      <xsl:attribute name="ID">
        <xsl:value-of select="$identifier"/>
      </xsl:attribute>
      <xsl:if test="normalize-space($relatedAgents) != ''">
        <xsl:variable name="agents">
          <xsl:value-of select='normalize-space($relatedAgents)'/>
        </xsl:variable>
        <xsl:attribute name="ADMID">
          <xsl:value-of select="$agents"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="mdwrap-xmldata-bucket">
        <xsl:with-param name="contents">
          <xsl:copy-of select="$contents"/>
        </xsl:with-param>
        <xsl:with-param name="mdtype">PREMIS</xsl:with-param>
      </xsl:call-template>
    </rightsMD>
  </xsl:template>

  <!-- list linking objects that match the identifier type and value -->
  <xsl:template name="relationship_linking">
    <xsl:param name="otype"/>
    <xsl:param name="ovalue"/>

     <!-- check if any bistreams match -->
     <xsl:for-each select="/premis:premis/premis:object[@xsi:type='bitstream']">
       <xsl:if test="normalize-space(premis:objectIdentifier/premis:objectIdentifierType)=$otype and
                     normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)=$ovalue">
         <xsl:text> </xsl:text>
         <xsl:text>bitstream-</xsl:text><xsl:value-of select="position()" />
       </xsl:if>
     </xsl:for-each>
    
     <!-- check if any representations match -->
     <xsl:for-each select="/premis:premis/premis:object[@xsi:type='representation']">
       <xsl:if test="normalize-space(premis:objectIdentifier/premis:objectIdentifierType)=$otype and
                     normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)=$ovalue">
         <xsl:text> </xsl:text>
         <xsl:text>representation-</xsl:text><xsl:value-of select="position()" />
       </xsl:if>
     </xsl:for-each>
    
     <!-- check if any files match -->
     <xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
       <xsl:if test="normalize-space(premis:objectIdentifier/premis:objectIdentifierType)=$otype and
                     normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)=$ovalue">
         <xsl:text> </xsl:text>
         <xsl:text>object-</xsl:text><xsl:value-of select="position()" />
       </xsl:if>
     </xsl:for-each>    
  
  </xsl:template>
	
</xsl:stylesheet>
