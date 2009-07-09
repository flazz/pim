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
        <xsl:value-of select="normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)"/>
      </xsl:attribute>

      <!-- size -->
      <xsl:if test="premis:objectCharacteristics/premis:size">
        <xsl:attribute name="SIZE">
          <xsl:value-of select="normalize-space(premis:objectCharacteristics/premis:size)"/>
        </xsl:attribute>
      </xsl:if>

      <!-- checksum if it exists-->
      <xsl:if test="premis:objectCharacteristics/premis:fixity">
        <xsl:attribute name="CHECKSUM">
          <xsl:value-of select="normalize-space(premis:objectCharacteristics/premis:fixity[1]/premis:messageDigest)"/>
        </xsl:attribute>
        <xsl:if test="contains('HAVAL MD5 SHA-1 SHA-256 SHA-384 SHA-512 TIGER WHIRLPOOL', premis:objectCharacteristics/premis:fixity[1]/premis:messageDigestAlgorithm)">
          <xsl:attribute name="CHECKSUMTYPE">
            <xsl:value-of select="normalize-space(premis:objectCharacteristics/premis:fixity[1]/premis:messageDigestAlgorithm)"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>

      <!-- figure out an FLocat -->
      <xsl:if test="premis:storage/premis:contentLocation">
        <FLocat>
          <xsl:choose>
            <xsl:when test="contains('ARK URN URL PURL HANDLE DOI', premis:storage/premis:contentLocation/premis:contentLocationType)">
              <xsl:attribute name="LOCTYPE">
                <xsl:value-of select="normalize-space(premis:storage/premis:contentLocation/premis:contentLocationType)"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="LOCTYPE">
                <xsl:text>OTHER</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="OTHERLOCTYPE">
                <xsl:value-of select="normalize-space(premis:storage/premis:contentLocation/premis:contentLocationType)"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:attribute name="xlink:href">
            <xsl:value-of select="normalize-space(premis:storage/premis:contentLocation/premis:contentLocationValue)"/>
          </xsl:attribute>
        </FLocat>
      </xsl:if>
    </file>
  </xsl:template>


  <!-- make a structMap for every structural representation with files -->
  <xsl:template match="premis:premis/premis:object[@xsi:type='representation']">
    <xsl:param name="container"/>

    <xsl:variable name="otype">
      <xsl:value-of select="normalize-space(premis:objectIdentifier/premis:objectIdentifierType)"/>					
    </xsl:variable>          
    <xsl:variable name="ovalue">
      <xsl:value-of select="normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)"/>
    </xsl:variable>
    
    <!-- only make a structMap if this representation has files -->
    <xsl:if test="premis:relationship[normalize-space(premis:relationshipType)='structural' and 
                                      normalize-space(premis:relationshipSubType)='includes']">
    <structMap>
    
      <div>
        
        <xsl:if test="not($container)">
          <xsl:attribute name="ADMID">
            <xsl:text>representation-</xsl:text><xsl:value-of select="position()"/>
          </xsl:attribute>     
        </xsl:if>
        
        <!-- add files to a representation -->
        <xsl:for-each select="premis:relationship[normalize-space(premis:relationshipSubType)='includes']/premis:relatedObjectIdentification">
          <xsl:call-template name="representation_files">
            <xsl:with-param name="oValue" select="normalize-space(premis:relatedObjectIdentifierValue)"/>
            <xsl:with-param name="oType" select="normalize-space(premis:relatedObjectIdentifierType)"/>
          </xsl:call-template>   
        </xsl:for-each>
    
      </div>
    </structMap>
    </xsl:if>
  </xsl:template>

  
  <!-- list all files structurally included by a representation -->
  <xsl:template name="representation_files">
    <xsl:param name="oType"/>
    <xsl:param name="oValue"/>
    
    <xsl:for-each select="//premis:object[@xsi:type='file']">
      <xsl:if test="normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)=$oValue and
                   normalize-space(premis:objectIdentifier/premis:objectIdentifierType)=$oType">
        <fptr>
          <xsl:attribute name="FILEID">
            <xsl:text>file-</xsl:text><xsl:value-of select="position()" />
          </xsl:attribute>
        </fptr>
      </xsl:if>
    </xsl:for-each>

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



  <!-- Create a structMap for files not in a representation -->
  <xsl:template name="orphaned-file-map">

    <!-- start at a given position -->
    <xsl:param name="position">1</xsl:param>
    
    <!-- have we seen any orphaned nodes yet? -->
    <xsl:param name="orphans">false</xsl:param>
    
    <xsl:if test="$position &lt; count(//premis:object[@xsi:type='file'])+1">
      
      <!-- loop through the files; compare the one at the right position -->
      <xsl:for-each select="//premis:object[@xsi:type='file']">
        <xsl:if test="position()=$position">

          <xsl:variable name="ftype">
            <xsl:value-of select="normalize-space(premis:objectIdentifier/premis:objectIdentifierType)"/>					
          </xsl:variable>          
          <xsl:variable name="fvalue">
            <xsl:value-of select="normalize-space(premis:objectIdentifier/premis:objectIdentifierValue)"/>
          </xsl:variable>      
  
          <xsl:choose>

            <!-- recurse if this node isn't an orphan -->
            <xsl:when test="//premis:object[@xsi:type='representation' and 
                    normalize-space(premis:relationship/premis:relationshipType)='structural' and
                    normalize-space(premis:relationship/premis:relationshipSubType)='includes' and
                    normalize-space(premis:relationship//premis:relatedObjectIdentifierValue)=$fvalue and
                    normalize-space(premis:relationship//premis:relatedObjectIdentifierType)=$ftype]">

              <xsl:call-template name="orphaned-file-map">
                <xsl:with-param name="position" select="$position+1"/>
                <xsl:with-param name="orphans" select="$orphans"/>
              </xsl:call-template>

            </xsl:when>

            <!-- orphan file -->
            <xsl:otherwise>

              <xsl:choose>
 
                <!-- create a structMap if this is our first sighting -->
                <xsl:when test="$orphans='false'">
 
                  <structMap LABEL="ORPHANED_FILES">
                    <div>
                      <fptr>
                        <xsl:attribute name="FILEID">
                          <xsl:text>file-</xsl:text><xsl:value-of select="$position" />
                        </xsl:attribute>
                      </fptr>

                      <xsl:call-template name="orphaned-file-map">
                        <xsl:with-param name="position" select="$position+1"/>
                        <xsl:with-param name="orphans" select="true()"/>
                      </xsl:call-template>
 
                    </div>
                  </structMap>
 
                </xsl:when>
 
                <!-- just create a fptr if we've seen other orphans -->
                <xsl:otherwise>

                  <fptr>
                    <xsl:attribute name="FILEID">
                      <xsl:text>file-</xsl:text><xsl:value-of select="$position" />
                    </xsl:attribute>
                  </fptr>

                  <xsl:call-template name="orphaned-file-map">
                    <xsl:with-param name="position" select="$position+1"/>
                    <xsl:with-param name="orphans" select="$orphans"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            
            </xsl:otherwise>
          </xsl:choose>

        </xsl:if>
      </xsl:for-each>

    </xsl:if>
  
  </xsl:template>
         
</xsl:stylesheet>