<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.lvc_d53_h3b"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Handles a <xdoc:dum-parameters> element and outputs any parameters into the DocBook source.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/xdoclib.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-parameters" as="xs:string" required="yes"/>
  <xsl:param name="parameter-filters" as="xs:string" required="yes"/>

  <!-- This "parameter" comes in as an attribute on the root: <xdoc:dump-parameters type="comment|table">.
    Unless its set to table we're going to dump the stuff as a comment...
  -->
  <xsl:variable name="dump-type" as="xs:string" select="string(/*/@type)"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">

    <xsl:variable name="parameters" as="map(xs:string, xs:string*)"
      select="xdoc:parameters-get-with-filterstring($href-parameters, $parameter-filters)"/>

    <xsl:choose>

      <!-- Dump as table: -->
      <xsl:when test="$dump-type eq 'table'">
        <table xmlns="http://docbook.org/ns/docbook">
          <title>Parameters</title>
          <tgroup cols="2">
            <colspec colname="c1" colnum="1"/>
            <colspec colname="c2" colnum="2"/>
            <thead>
              <row>
                <entry>Parameter</entry>
                <entry>Value</entry>
              </row>
            </thead>
            <tbody>
              <xsl:for-each select="map:keys($parameters)">
                <xsl:sort select="."/>
                <row>
                  <entry>
                    <para>
                      <code>{.}</code>
                    </para>
                  </entry>
                  <entry>
                    <para>
                      <code>{ $parameters(.) }</code>
                    </para>
                  </entry>
                </row>
              </xsl:for-each>
            </tbody>
          </tgroup>
        </table>
      </xsl:when>

      <!-- Dump as comment: -->
      <xsl:otherwise>
        <xsl:variable name="parameter-strings" as="xs:string*">
          <xsl:for-each select="map:keys($parameters)">
            <xsl:sort select="."/>
            <xsl:sequence select=". || '=' || xtlc:q($parameters(.)[1])"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:comment> Parameters: { string-join($parameter-strings, '; ')} </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>
