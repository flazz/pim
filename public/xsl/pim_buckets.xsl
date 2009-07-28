<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:premis="info:lc/xmlns/premis-v2" 
	xmlns="http://www.loc.gov/METS/" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0">
	
  <xsl:import href="pim_base.xsl"/>

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
      
      
      <!-- agents linked to by this rights statement -->
      <xsl:with-param name="relatedAgents">
        <xsl:for-each select="premis:rightsStatement/premis:linkingAgentIdentifier">
          <xsl:call-template name="linking_agents">
            <xsl:with-param name="atype">
              <xsl:value-of select="normalize-space(premis:linkingAgentIdentifierType)"/>
            </xsl:with-param>
            <xsl:with-param name="avalue">
              <xsl:value-of select="normalize-space(premis:linkingAgentIdentifierValue)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:with-param>

      <!-- objects linked to by this rights statement -->
      <xsl:with-param name="relatedObjects">
        <xsl:for-each select="premis:rightsStatement/premis:linkingObjectIdentifier">
          <xsl:call-template name="linking_objects">
            <xsl:with-param name="otype">
              <xsl:value-of select="normalize-space(premis:linkingObjectIdentifierType)"/>
            </xsl:with-param>
            <xsl:with-param name="ovalue">
              <xsl:value-of select="normalize-space(premis:linkingObjectIdentifierValue)"/>
            </xsl:with-param>
          </xsl:call-template>
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

        <!-- objects linked to this event -->
        <xsl:for-each select="premis:linkingObjectIdentifier">
          <xsl:call-template name="linking_objects">
            <xsl:with-param name="otype">
              <xsl:value-of select="normalize-space(premis:linkingObjectIdentifierType)"/>
            </xsl:with-param>
            <xsl:with-param name="ovalue">
              <xsl:value-of select="normalize-space(premis:linkingObjectIdentifierValue)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      
      </xsl:with-param>
        
      <!-- agents related to this event -->
      <xsl:with-param name="relatedAgents">
        <xsl:for-each select="premis:linkingAgentIdentifier">
          <xsl:call-template name="linking_agents">
            <xsl:with-param name="atype">
              <xsl:value-of select="normalize-space(premis:linkingAgentIdentifierType)"/>
            </xsl:with-param>
            <xsl:with-param name="avalue">
              <xsl:value-of select="normalize-space(premis:linkingAgentIdentifierValue)"/>
            </xsl:with-param>
          </xsl:call-template>
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
      <xsl:if test="normalize-space(concat($relatedAgents, $relatedObjects)) != ''">
        <xsl:attribute name="ADMID">
          <xsl:value-of select="normalize-space(concat($relatedAgents, $relatedObjects))"/>
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
          <xsl:call-template name="linking_rights">
            <xsl:with-param name="rtype">
              <xsl:value-of select="normalize-space(premis:linkingRightsStatementIdentifierType)"/>
            </xsl:with-param>
            <xsl:with-param name="rvalue">
              <xsl:value-of select="normalize-space(premis:linkingRightsStatementIdentifierValue)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
    
      </xsl:variable>
      
      <xsl:variable name="relatedObjects">
        
        <!-- objects with relationships to this object -->
        <xsl:for-each select="premis:relationship/premis:relatedObjectIdentification">
          <xsl:call-template name="linking_objects">
            <xsl:with-param name="otype">
              <xsl:value-of select="normalize-space(premis:relatedObjectIdentifierType)"/>
            </xsl:with-param>
            <xsl:with-param name="ovalue">
              <xsl:value-of select="normalize-space(premis:relatedObjectIdentifierValue)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
    
      </xsl:variable>

      <xsl:variable name="relatedEvents">
        
        <!-- relationship events or events linked to this object -->
        <xsl:for-each select="premis:relationship/premis:relatedEventIdentification">
          <xsl:call-template name="linking_events">
            <xsl:with-param name="etype">
              <xsl:value-of select="normalize-space(premis:relatedEventIdentifierType)"/>
            </xsl:with-param>
            <xsl:with-param name="evalue">
              <xsl:value-of select="normalize-space(premis:relatedEventIdentifierValue)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
        
        <xsl:for-each select="premis:linkingEventIdentifier">
          <xsl:call-template name="linking_events">
            <xsl:with-param name="etype">
              <xsl:value-of select="normalize-space(premis:linkingEventIdentifierType)"/>
            </xsl:with-param>
            <xsl:with-param name="evalue">
              <xsl:value-of select="normalize-space(premis:linkingEventIdentifierValue)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
    
      </xsl:variable>


      <!-- if this element links to other PREMIS elements, create an ADMID -->
      <xsl:if test="normalize-space(concat($relatedRights, $relatedObjects, $relatedEvents)) != ''">
        <xsl:attribute name="ADMID">
          <xsl:value-of select="normalize-space(concat($relatedRights, $relatedObjects, $relatedEvents))"/>
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
    <xsl:param name="relatedObjects"/>
    
    <rightsMD>
      <xsl:attribute name="ID">
        <xsl:value-of select="$identifier"/>
      </xsl:attribute>
      <xsl:if test="normalize-space(concat($relatedObjects, $relatedAgents)) != ''">
        <xsl:attribute name="ADMID">
          <xsl:value-of select="normalize-space(concat($relatedAgents, $relatedObjects))"/>
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

  <!-- objects that match the identifier type and value -->
  <xsl:template name="linking_objects">
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

  <!-- agents that match the identifier type and value -->
  <xsl:template name="linking_agents">
    <xsl:param name="atype"/>
    <xsl:param name="avalue"/>

     <xsl:for-each select="/premis:premis/premis:agent">
       <xsl:if test="normalize-space(premis:agentIdentifier/premis:agentIdentifierType)=$atype and
                     normalize-space(premis:agentIdentifier/premis:agentIdentifierValue)=$avalue">
         <xsl:text> </xsl:text>
         <xsl:text>agent-</xsl:text><xsl:value-of select="position()" />
       </xsl:if>
     </xsl:for-each>
       
  </xsl:template>

  <!-- rights that match the identifier type and value -->
  <xsl:template name="linking_rights">
    <xsl:param name="rtype"/>
    <xsl:param name="rvalue"/>

     <xsl:for-each select="/premis:premis/premis:rights">
       <xsl:if test="normalize-space(premis:rightsStatement/premis:rightsStatementIdentifier/premis:rightsStatementIdentifierType)=$rtype and
                     normalize-space(premis:rightsStatement/premis:rightsStatementIdentifier/premis:rightsStatementIdentifierValue)=$rvalue">
         <xsl:text> </xsl:text>
         <xsl:text>rights-</xsl:text><xsl:value-of select="position()" />
       </xsl:if>
     </xsl:for-each>
       
  </xsl:template>

  <!-- list linking events that match the identifier type and value -->
  <xsl:template name="linking_events">
    <xsl:param name="etype"/>
    <xsl:param name="evalue"/>

     <xsl:for-each select="/premis:premis/premis:event">
       <xsl:if test="normalize-space(premis:eventIdentifier/premis:eventIdentifierType)=$etype and
                     normalize-space(premis:eventIdentifier/premis:eventIdentifierValue)=$evalue">
         <xsl:text> </xsl:text>
         <xsl:text>event-</xsl:text><xsl:value-of select="position()" />
       </xsl:if>
     </xsl:for-each>
       
  </xsl:template>
	
</xsl:stylesheet>
