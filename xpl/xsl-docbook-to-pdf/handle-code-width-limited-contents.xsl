<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*	
    Handle columns contents with <code role="code-width-limited">
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/xdoclib.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="main-font-size" as="xs:string" required="true"/>
  <xsl:variable name="main-font-size-dbl" as="xs:double" select="xs:double($main-font-size)"/>

  <!-- ================================================================== -->
  <!-- GLOBALS: -->

  <xsl:variable name="code-width-limited-role" as="xs:string" select="'code-width-limited'"/>

  <!-- An educated guess about the number of fixed width characters per cm.  -->
  <xsl:variable name="fixed-width-characters-per-cm-dbl" as="xs:double" select="xdoc:fixed-width-characters-per-cm-dbl($main-font-size-dbl)"/>

  <!-- ================================================================== -->

  <xsl:template match="db:entry/db:para[exists(db:code[local:is-code-width-limited(.)])]">
    <!-- A db:code inside a db:entry/db:para. Remove the db:para (this will be added again later) -->
    <xsl:for-each select="db:code[local:is-code-width-limited(.)]">
      <xsl:call-template name="handle-code"/>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:entry/db:code[local:is-code-width-limited(.)]">
    <xsl:call-template name="handle-code"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="handle-code">
    <xsl:param name="code" as="element(db:code)" required="no" select="."/>

    <xsl:for-each select="$code">

      <!-- Find out what column we have and from there the column specification: -->
      <xsl:variable name="entry" as="element(db:entry)" select="ancestor::db:entry[1]"/>
      <xsl:variable name="column-number" as="xs:integer" select="count($entry/preceding-sibling::db:entry) + 1"/>
      <xsl:variable name="colspec" as="element(db:colspec)" select="($entry/ancestor::db:tgroup[1])/db:colspec[$column-number]"/>

      <!-- Get the actual width: -->
      <xsl:variable name="colwidth-full" as="xs:string" select="string($colspec/@colwidth)"/>
      <xsl:if test="not(ends-with($colwidth-full, 'cm'))">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts"
            select="('Column width not expressed in cm (for handling of ', $code-width-limited-role, '): ', xtlc:q($colwidth-full))"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:variable name="colwidth-str" as="xs:string" select="substring-before($colwidth-full, 'cm')"/>
      <xsl:if test="not($colwidth-str castable as xs:double)">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Invalid column width expression: ', xtlc:q($colwidth-full))"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:variable name="width-cm" as="xs:double" select="xs:double($colwidth-str)"/>

      <!-- Now try to make it fit: -->
      <xsl:variable name="text" as="xs:string" select="string(.)"/>
      <xsl:choose>
        <xsl:when test="contains($text, ' ') or contains($text, '-')">
          <!-- Assume the text will break "naturally"... -->
          <para>
            <code>
              <xsl:value-of select="$text"/>
            </code>
          </para>
        </xsl:when>
        <xsl:otherwise>
          <!-- Perform nifty calculations and break the line: -->
          <xsl:variable name="characters-per-line" as="xs:integer" select="xs:integer(floor( ($width-cm - 0.3) * $fixed-width-characters-per-cm-dbl))"/>
          <xsl:variable name="nr-of-lines" as="xs:integer" select="xs:integer(ceiling(string-length($text) div $characters-per-line))"/>
          <xsl:for-each select="1 to $nr-of-lines">
            <xsl:variable name="line-nr" as="xs:integer" select="."/>
            <para>
              <code>
                <xsl:value-of select="substring($text, 1 + (($line-nr - 1) * $characters-per-line), $characters-per-line)"/>
              </code>
            </para>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:for-each>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:is-code-width-limited" as="xs:boolean">
    <xsl:param name="code-elm" as="element(db:code)"/>
    <xsl:sequence select="$code-width-limited-role = xtlc:str2seq($code-elm/@role)"/>
  </xsl:function>

</xsl:stylesheet>
