<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:premis="info:lc/xmlns/premis-v2"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="1.0">

  <xsl:template match="/">
    <html>

      <head>

        <link type="text/css" href="/css/ui-lightness/jquery-ui-1.7.1.custom.css" rel="Stylesheet" />
        <script type="text/javascript" src="/js/jquery-1.3.2.min.js"></script>
        <script type="text/javascript" src="/js/jquery-ui-1.7.1.custom.min.js"></script>

        <script type="text/javascript" src="/js/local.js"></script>
        <link rel="stylesheet" href="/css/local.css" type="text/css" media="screen, projection"/>

        <title>
          PREMIS in METS document
        </title>

        <style type="text/css">
          h1 {color: #e40045}
          h2 {color: #94002d}
          .mdsection { width: 85%; background-color: #a9f16c; padding:1ex; padding-top:1ex }
          .mdsection h3 { width: 100%; background-color: #64aa2b; padding:1ex; font-weight: bold; width:auto}
          .mdsection table { width: 100%;  }
          .mdsection th { text-align:right; width:20%; color:#439400;}
          .mdsection li { font-size: 1.5em; list-style-type: square }
        </style>

      </head>

      <body>

        <div class="container">

          <h1>Administrative metadata</h1>

          <xsl:for-each select="/mets:mets/mets:amdSec">

            <h2>Technical</h2>
            <xsl:for-each select="mets:techMD">
              <div class="mdsection">
                <xsl:apply-templates select="mets:mdWrap/mets:xmlData/*"/>
              </div>
            </xsl:for-each>

            <h2>Rights</h2>
            <xsl:for-each select="mets:rightsMD">
              <div class="mdsection">
                <xsl:value-of select="@ID"/>
              </div>
            </xsl:for-each>

            <h2>Digital Provenance</h2>
            <xsl:for-each select="mets:digiprovMD">
              <div class="mdsection">
                <xsl:apply-templates select="mets:mdWrap/mets:xmlData/*"/>
              </div>
            </xsl:for-each>

          </xsl:for-each>

          <h1>Files</h1>
          <div class="mdsection">
            <ul>
              <xsl:apply-templates select="//mets:file"/>
            </ul>
          </div>

        </div>

      </body>

    </html>
  </xsl:template>

  <xsl:template match="premis:object">

    <h3>
      <xsl:value-of select="@xsi:type"/>
      object:
      <xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierValue"/>
      (<xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierType"/>)
    </h3>

    <table>

      <tr>
        <th>composition level</th>
        <td><xsl:value-of select="premis:objectCharacteristics/premis:compositionLevel"/></td>
      </tr>

      <xsl:for-each select="premis:objectCharacteristics/premis:fixity">
        <tr>
          <th><xsl:value-of select="premis:messageDigestAlgorithm"/></th>
          <td><xsl:value-of select="premis:messageDigest"/></td>
        </tr>
      </xsl:for-each>

      <tr>
        <th>size</th>
        <td><xsl:value-of select="premis:objectCharacteristics/premis:size"/> bytes</td>
      </tr>

      <xsl:for-each select="premis:objectCharacteristics/premis:format">

        <xsl:if test="premis:formatDesignation">
          <tr>
            <th>format designation</th>
            <td>
              <xsl:value-of select="premis:formatDesignation/premis:formatName"/>
              <xsl:if test="premis:formatDesignation/premis:formatVersion">
                (<xsl:value-of select="premis:formatDesignation/premis:formatVersion"/>)
              </xsl:if>
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="premis:formatRegistry">
          <tr>
            <th>format registry</th>
            <td>
              <xsl:value-of select="premis:formatRegistry/premis:formatRegistryKey"/>
              (<xsl:value-of select="premis:formatRegistry/premis:formatRegistryName"/>)
            </td>
          </tr>
        </xsl:if>

      </xsl:for-each>

      <xsl:for-each select="premis:storage">
        <tr>
          <th>location</th>
          <td>
            <xsl:value-of select="premis:contentLocation/premis:contentLocationValue"/>
            (<xsl:value-of select="premis:contentLocation/premis:contentLocationType"/>,
            <xsl:value-of select="premis:storageMedium"/>)
          </td>
        </tr>
      </xsl:for-each>


    </table>

  </xsl:template>

  <xsl:template match="premis:event">

    <h3>
      event:
      <xsl:value-of select="premis:eventIdentifier/premis:eventIdentifierValue"/>
      (<xsl:value-of select="premis:eventIdentifier/premis:eventIdentifierType"/>)
    </h3>

    <table>

      <tr>
        <th>date-time</th>
        <td><xsl:value-of select="premis:eventDateTime"/></td>
      </tr>

      <tr>
        <th>type</th>
        <td><xsl:value-of select="premis:eventType"/></td>
      </tr>

      <tr>
        <th>outcome</th>
        <td><xsl:value-of select="premis:eventOutcomeInformation/premis:eventOutcome"/></td>
      </tr>

    </table>

  </xsl:template>

  <xsl:template match="premis:agent">
    <h3>
      agent:
      <xsl:value-of select="premis:agentIdentifier/premis:agentIdentifierValue"/>
      (<xsl:value-of select="premis:agentIdentifier/premis:agentIdentifierType"/>)
    </h3>
    <table>
      <tr>
        <th>name</th>
        <td><xsl:value-of select="premis:agentName"/></td>
      </tr>
      <tr>
        <th>type</th>
        <td><xsl:value-of select="premis:agentType"/></td>
      </tr>
    </table>

  </xsl:template>

  <xsl:template match="mets:file">

    <li>
      <xsl:value-of select="@ID"/>
      (<xsl:value-of select="@SIZE"/> bytes)
    </li>

  </xsl:template>

</xsl:stylesheet>