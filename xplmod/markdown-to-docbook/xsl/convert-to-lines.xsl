<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.zkx_5pg_2jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" exclude-result-prefixes="#all" xmlns:db="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    This is the first stage of the Markdown conversion process.
    
    Takes the raw text and turns this into <line indent="..."> elements (surrounded by an <xdoc:GROUP>).
    The indent is adjusted when the text is indented as a whole block (which is normal in code).
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xdoc:GROUP>

      <!-- Turn the block of text into individual lines: -->
      <xsl:variable name="fulltext-no-cr" as="xs:string" select="translate(string(/*), '&#13;', '')"/>
      <xsl:variable name="textlines-raw" as="xs:string*" select="tokenize($fulltext-no-cr, '&#10;')"/>

      <!-- Turn into a sequence of line elements. Record the number of prefix spacing in @indent and then normalize all lines: -->
      <xsl:variable name="lines-raw" as="element(db:line)*">
        <xsl:for-each select="$textlines-raw">
          <line>
            <xsl:variable name="start-space-character-count" as="xs:integer" select="local:count-start-characters(., ' ')"/>
            <xsl:attribute name="indent" select="$start-space-character-count"/>
            <xsl:value-of select="normalize-space(.)"/>
          </line>
        </xsl:for-each>
      </xsl:variable>

      <!-- Find the main indent. This is defined as the minimum number of initial spacing of non-empty lines. 
        The assumption is this text comes from code and might be indented as a full block.
      -->
      <xsl:variable name="indents-non-empty-lines" as="xs:integer*"
        select="for $non-empty-line in $lines-raw[string(.) ne ''] return xs:integer($non-empty-line/@indent)"/>
      <xsl:variable name="main-indent" as="xs:integer" select="(min($indents-non-empty-lines), 0)[1]"/>

      <!-- Adjust the indents accordingly: -->
      <xsl:for-each select="$lines-raw">
        <xsl:copy copy-namespaces="false">
          <xsl:variable name="indent" as="xs:integer" select="xs:integer(@indent)"/>
          <xsl:attribute name="indent">
            <xsl:choose>
              <xsl:when test="string(.) eq ''">
                <xsl:sequence select="0"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$indent - $main-indent"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </xsl:copy>
      </xsl:for-each>

    </xdoc:GROUP>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:function name="local:count-start-characters" as="xs:integer">
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="char" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="($text eq '') or ($char eq '')">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:when test="substring($text, 1, 1) eq substring($char, 1, 1)">
        <xsl:sequence select="local:count-start-characters(substring($text, 2), $char) + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

</xsl:stylesheet>
