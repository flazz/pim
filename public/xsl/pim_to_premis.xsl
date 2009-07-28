<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns = "info:lc/xmlns/premis-v2" 
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:premis="info:lc/xmlns/premis-v2" 
	exclude-result-prefixes="mets premis"
	version="1.0">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">

    <premis xmlns="info:lc/xmlns/premis-v2"
            xmlns:xlink="http://www.w3.org/1999/xlink" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/premis.xsd" version="2.0">
      <xsl:choose>

        <xsl:when test="//mets:digiprovMD/mets:mdWrap/mets:xmlData/premis:premis">
          <xsl:copy-of select="//premis:premis/*" />
        </xsl:when>

        <xsl:otherwise>

          <xsl:copy-of select="//mets:digiprovMD//premis:object[xsi:type='representation']"/>

          <xsl:copy-of select="//mets:techMD//premis:object"/>

          <xsl:copy-of select="//mets:digiprovMD//premis:event"/>

          <xsl:copy-of select="//mets:digiprovMD//premis:agent"/>

          <xsl:copy-of select="//mets:rightsMD//premis:agent"/>

          <xsl:copy-of select="//mets:rightsMD//premis:rights"/>

        </xsl:otherwise>

      </xsl:choose>

    </premis>
  
  </xsl:template>

</xsl:stylesheet>