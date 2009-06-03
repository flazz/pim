<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:premis="info:lc/xmlns/premis-v2"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                version="1.0">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:processing-instruction name="xml-stylesheet">href="pim2html.xsl" type="text/xsl"</xsl:processing-instruction>
    <mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
      
      <amdSec>
        <xsl:apply-templates select="premis:premis"/>
      </amdSec>

      <fileSec>
        <fileGrp>
          <xsl:apply-templates select="premis:premis/premis:object[@xsi:type='file']" mode="file"/>
        </fileGrp>
      </fileSec>

      <!-- TODO suport structural representations -->
      <structMap>
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

  <!-- make a mets file element -->
  <xsl:template match="premis:object[@xsi:type='file']" mode="file">
    <file xmlns="http://www.loc.gov/METS/">

      <!-- make the ID -->
      <xsl:attribute name="ID">
        <xsl:text>file-</xsl:text>
        <xsl:value-of select="position()"/>
      </xsl:attribute>

      <!-- get the first message digest if it exists -->
      <xsl:if test="premis:objectCharacteristics/premis:fixity">
        <xsl:attribute name="CHECKSUMTYPE">
          <xsl:value-of select="premis:objectCharacteristics/premis:fixity[1]/premis:messageDigestAlgorithm"/>
        </xsl:attribute>

        <xsl:attribute name="CHECKSUM">
          <xsl:value-of select="premis:objectCharacteristics/premis:fixity[1]/premis:messageDigest"/>
        </xsl:attribute>
      </xsl:if>

      <!-- figure out an Flocat -->
      <xsl:if test="premis:storage/premis:contentLocation">
        <FLocat xmlns="http://www.loc.gov/METS/">
          <xsl:attribute name="LOCTYPE">
            <xsl:value-of select="premis:storage/premis:contentLocation/premis:contentLocationType"/>
          </xsl:attribute>
          <xsl:attribute name="href" namespace="http://www.w3.org/1999/xlink">
            <xsl:value-of select="premis:storage/premis:contentLocation/premis:contentLocationValue"/>
          </xsl:attribute>
        </FLocat>
      </xsl:if>

    </file>
  </xsl:template>

  <!-- make a mets file pointer object -->
  <xsl:template match="premis:object[@xsi:type='file']" mode="filep">
    <fptr xmlns="http://www.loc.gov/METS/">
      <xsl:attribute name="FILEID">
        <xsl:text>file-</xsl:text>
        <xsl:value-of select="position()"/>
      </xsl:attribute>
    </fptr>
  </xsl:template>

</xsl:stylesheet>
