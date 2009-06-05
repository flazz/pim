<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:premis="info:lc/xmlns/premis-v2" 
	xmlns="http://www.loc.gov/METS/" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	version="1.0">

	
  <!-- make a mets file element -->
  <xsl:template match="premis:premis/premis:object[@xsi:type='file']" mode="file">
    <xsl:param name="buckets"/>
    <file>

      <!-- ID -->
      <xsl:attribute name="ID">
        <xsl:text>file-</xsl:text><xsl:value-of select="position()"/>
      </xsl:attribute>

      <xsl:if test="$buckets">
        <!-- ADMID -->
        <xsl:attribute name="ADMID">
          <xsl:text>object-</xsl:text><xsl:value-of select="position()"/>
        </xsl:attribute>
      </xsl:if>
      
      <!-- OWNERID -->
      <xsl:attribute name="OWNERID">
        <xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierValue"/>
      </xsl:attribute>

      <!-- size -->
      <xsl:if test="premis:objectCharacteristics/premis:size">
        <xsl:attribute name="SIZE">
          <xsl:value-of select="premis:objectCharacteristics/premis:size"/>
        </xsl:attribute>
      </xsl:if>

      <!-- checksum if it exists-->
      <xsl:if test="premis:objectCharacteristics/premis:fixity">
        <xsl:attribute name="CHECKSUM">
          <xsl:value-of select="premis:objectCharacteristics/premis:fixity[1]/premis:messageDigest"/>
        </xsl:attribute>
        <xsl:if test="contains('HAVAL MD5 SHA-1 SHA-256 SHA-384 SHA-512 TIGER WHIRLPOOL', premis:objectCharacteristics/premis:fixity[1]/premis:messageDigestAlgorithm)">
          <xsl:attribute name="CHECKSUMTYPE">
            <xsl:value-of select="premis:objectCharacteristics/premis:fixity[1]/premis:messageDigestAlgorithm"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>

      <!-- figure out an FLocat -->
      <xsl:if test="premis:storage/premis:contentLocation">
        <FLocat>
          <xsl:choose>
            <xsl:when test="contains('ARK URN URL PURL HANDLE DOI', premis:storage/premis:contentLocation/premis:contentLocationType)">
              <xsl:attribute name="LOCTYPE">
                <xsl:value-of select="premis:storage/premis:contentLocation/premis:contentLocationType"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="LOCTYPE">
                <xsl:text>OTHER</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="OTHERLOCTYPE">
                <xsl:value-of select="premis:storage/premis:contentLocation/premis:contentLocationType"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:attribute name="xlink:href">
            <xsl:value-of select="premis:storage/premis:contentLocation/premis:contentLocationValue"/>
          </xsl:attribute>
        </FLocat>
      </xsl:if>
    </file>
  </xsl:template>


  <!-- make a structMap for every major representation -->
  <xsl:template match="premis:premis/premis:object[@xsi:type='representation' and 
                       premis:relationship/premis:relationshipType='structural']">

    <xsl:variable name="otype">
      <xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierType"/>					
    </xsl:variable>          
    <xsl:variable name="ovalue">
      <xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierValue"/>
    </xsl:variable>
    
    <!-- only make a div if this representation isn't part of something else -->
    <xsl:if test="not($ovalue = //premis:object[@xsi:type='representation' and
                                premis:relationship/premis:relationshipType='structural' and
                                premis:relationship/premis:relationshipSubType='has part']//premis:relatedObjectIdentifierValue)">
    <structMap>
      <div>
    
        <!-- label the representation -->
        <xsl:attribute name="LABEL">
          <xsl:value-of select="$ovalue"/>
        </xsl:attribute>

        <!-- add embedded representations -->
        <xsl:for-each select="premis:relationship[premis:relationshipSubType='has part']/premis:relatedObjectIdentification">
          <xsl:call-template name="inner_representations">
            <xsl:with-param name="rValue" select="premis:relatedObjectIdentifierValue"/>
            <xsl:with-param name="rType" select="premis:relatedObjectIdentifierType"/>
          </xsl:call-template>
        </xsl:for-each>

        <!-- add files to a representation -->
        <xsl:for-each select="premis:relationship[premis:relationshipSubType='includes']/premis:relatedObjectIdentification">
          <xsl:call-template name="representation_files">
            <xsl:with-param name="oValue" select="premis:relatedObjectIdentifierValue"/>
            <xsl:with-param name="oType" select="premis:relatedObjectIdentifierType"/>
          </xsl:call-template>   
        </xsl:for-each>
    
      </div>
    </structMap>
    </xsl:if>
  </xsl:template>


  <!-- make a div for an internal representation -->
  <xsl:template name="inner_representations">
    <xsl:param name="rType"/>
    <xsl:param name="rValue"/>
    
    <div>
    
      <!-- label the representation -->
      <xsl:attribute name="LABEL">
        <xsl:value-of select="$rValue"/>
      </xsl:attribute>

      <!-- add embedded representations -->
      <xsl:for-each select="//premis:object[@xsi:type='representation' and
                            premis:objectIdentifier/premis:objectIdentifierType=$rType and
                            premis:objectIdentifier/premis:objectIdentifierValue=$rValue
                            ]/premis:relationship[premis:relationshipSubType='has part']/premis:relatedObjectIdentification">
        <xsl:call-template name="inner_representations">
          <xsl:with-param name="rValue" select="premis:relatedObjectIdentifierValue"/>
          <xsl:with-param name="rType" select="premis:relatedObjectIdentifierType"/>
        </xsl:call-template>
      </xsl:for-each>

      <!-- add files to a representation -->
      <xsl:for-each select="//premis:object[@xsi:type='representation' and
                            premis:objectIdentifier/premis:objectIdentifierType=$rType and
                            premis:objectIdentifier/premis:objectIdentifierValue=$rValue
                            ]/premis:relationship[premis:relationshipSubType='includes']/premis:relatedObjectIdentification">

        <xsl:call-template name="representation_files">
          <xsl:with-param name="oValue" select="premis:relatedObjectIdentifierValue"/>
          <xsl:with-param name="oType" select="premis:relatedObjectIdentifierType"/>
        </xsl:call-template>
      </xsl:for-each>
    
    </div>
       
  </xsl:template>
 
  
  <!-- list all files structurally included by a representation -->
  <xsl:template name="representation_files">
    <xsl:param name="oType"/>
    <xsl:param name="oValue"/>
    
    <xsl:for-each select="//premis:object[@xsi:type='file']">
      <xsl:if test="premis:objectIdentifier/premis:objectIdentifierValue=$oValue and
                   premis:objectIdentifier/premis:objectIdentifierType=$oType">
        <fptr>
          <xsl:attribute name="FILEID">
            <xsl:text>file-</xsl:text><xsl:value-of select="position()" />
          </xsl:attribute>
        </fptr>
      </xsl:if>
    </xsl:for-each>

  </xsl:template>

	
  <!-- make a flat structMap for all files -->
  <xsl:template match="premis:premis/premis:object[@xsi:type='file']" mode="filep">

  <fptr>
    <!-- ID -->
    <xsl:attribute name="FILEID">
      <xsl:text>file-</xsl:text><xsl:value-of select="position()" />
    </xsl:attribute>
  </fptr>

  </xsl:template>

  <!-- mets mdWrap/xmlData bucket -->
  <xsl:template name="mdwrap-xmldata-bucket">
    <xsl:param name="contents"/>
    <xsl:param name="mdtype"/>
    
    <mdWrap MDTYPE="$mdtype">
      <xsl:attribute name="MDTYPE">
        <xsl:value-of select="$mdtype"/>
      </xsl:attribute>
      
      <xmlData>
        <xsl:copy-of select="$contents"/>
      </xmlData>
    </mdWrap>
  </xsl:template>

</xsl:stylesheet>