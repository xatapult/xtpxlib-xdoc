<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.zkx_5pg_2jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" exclude-result-prefixes="#all" xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns="http://docbook.org/ns/docbook" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Markdown conversion process.
    
    Takes the raw text and turns this into <line indent="..."> elements.
    The indent is adjusted when the text is indented as a whole block (which is normal in code).
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../../xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="xdoc:MARKDOWN">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      
      <xsl:variable name="lines-raw" as="xs:string*" select="xtlc:text2lines(string(/*), true(), true())"/>
      <xsl:for-each select="xtlc:text2lines(string(/*), true(), true())">
        <line indent="{xtlc:count-leading-whitespace(.)}">
          <xsl:value-of select="normalize-space(.)"/>
        </line>
      </xsl:for-each>

    </xsl:copy>
  </xsl:template>
  

</xsl:stylesheet>
