<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.zkx_5pg_3jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" exclude-result-prefixes="#all" xmlns:db="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    This is the second stage of the Markdown conversion process.
    
    It groups lines that belong together into a single paragraph. Takes care of code listings.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:variable name="code-block-marker" as="xs:string" select="'```'"/>

  <!-- ================================================================== -->

  <xsl:template match="xdoc:GROUP[exists(db:line)]">
    <xsl:copy copy-namespaces="false">
      <xsl:copy-of select="@*"/>

      <xsl:iterate select="db:line">
        <xsl:param name="in-grouping" as="xs:boolean" select="false()"/>
        <xsl:param name="group" as="element(db:line)*" select="()"/>
        <xsl:on-completion>
          <xsl:if test="$in-grouping">
            <xsl:call-template name="output-group">
              <xsl:with-param name="line-group" select="$group"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:on-completion>

        <xsl:variable name="line" as="xs:string" select="string(.)"/>
        <xsl:variable name="line-is-empty" as="xs:boolean" select="$line eq ''"/>
        <xsl:variable name="line-is-code-block-marker" as="xs:boolean" select="starts-with($line, $code-block-marker)"/>
        <xsl:variable name="line-starts-with-special" as="xs:boolean" select="matches($line, '^[0-9]\.|#|-')"/>

        <xsl:choose>
          <!-- If we're not grouping yet, every empty line starts a group: -->
          <xsl:when test="not($in-grouping) and not($line-is-empty)">
            <xsl:next-iteration>
              <xsl:with-param name="in-grouping" select="true()"/>
              <xsl:with-param name="group" select="."/>
            </xsl:next-iteration>
          </xsl:when>
          <!-- We're grouping and found a line that starts something special (header, list). Output the collected group and start a new one: -->
          <xsl:when test="$in-grouping and $line-starts-with-special">
            <xsl:call-template name="output-group">
              <xsl:with-param name="line-group" select="$group"/>
            </xsl:call-template>
            <xsl:next-iteration>
              <xsl:with-param name="in-grouping" select="true()"/>
              <xsl:with-param name="group" select="."/>
            </xsl:next-iteration>
          </xsl:when>
          <!-- When we're grouping and find a code-block marker, this belongs to the group and ends it: -->
          <xsl:when test="$in-grouping and $line-is-code-block-marker">
            <xsl:call-template name="output-group">
              <xsl:with-param name="line-group" select="($group, .)"/>
            </xsl:call-template>
            <xsl:next-iteration>
              <xsl:with-param name="in-grouping" select="false()"/>
              <xsl:with-param name="group" select="()"/>
            </xsl:next-iteration>
          </xsl:when>
          <!-- When we're grouping and find a n0n-empty line (that does not start with anything special, caught in the when's above), 
            this simply part of the group: -->
          <xsl:when test="$in-grouping and not($line-is-empty)">
            <xsl:next-iteration>
              <xsl:with-param name="in-grouping" select="true()"/>
              <xsl:with-param name="group" select="($group, .)"/>
            </xsl:next-iteration>
          </xsl:when>
          <!-- An empty line ends any grouping: -->
          <xsl:when test="$in-grouping and $line-is-empty">
            <xsl:call-template name="output-group">
              <xsl:with-param name="line-group" select="$group"/>
            </xsl:call-template>
            <xsl:next-iteration>
              <xsl:with-param name="in-grouping" select="false()"/>
              <xsl:with-param name="group" select="()"/>
            </xsl:next-iteration>
          </xsl:when>
          <xsl:otherwise>
            <!-- Ignore... -->
          </xsl:otherwise>
        </xsl:choose>

      </xsl:iterate>

    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-group">
    <xsl:param name="line-group" as="element(db:line)+" required="yes"/>

    <xsl:variable name="is-code-block" as="xs:boolean" select="starts-with(string($line-group[1]), $code-block-marker)"/>
    <xsl:choose>
      <xsl:when test="$is-code-block">
        <xsl:variable name="lines-to-include" as="element(db:line)*">
          <xsl:sequence select="$line-group[(position() gt 1) and (position() lt last())]"/>
          <!-- This is an exceptional situation (only happens when the code block is at the end and is not properly terminated): -->
          <xsl:if test="not(starts-with($line-group[last()], $code-block-marker))">
            <xsl:sequence select="$line-group[last()]"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="line-texts" as="xs:string*">
          <xsl:for-each select="$lines-to-include">
            <xsl:variable name="indent" as="xs:integer" select="xs:integer(@indent)"/>
            <xsl:variable name="indent-string" as="xs:string" select="string-join((1 to $indent)!' ')"/>
            <xsl:sequence select="$indent-string || string(.)"/>
          </xsl:for-each>
        </xsl:variable>
        <codelisting>
          <xsl:value-of select="string-join($line-texts, '&#10;')"/>
        </codelisting>
      </xsl:when>
      <xsl:otherwise>
        <para>
          <xsl:copy-of select="$line-group[1]/@indent"/>
          <xsl:value-of select="string-join($line-group/string(), ' ')"/>
        </para>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
