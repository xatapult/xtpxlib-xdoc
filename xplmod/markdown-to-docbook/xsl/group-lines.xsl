<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.zkx_5pg_3jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" exclude-result-prefixes="#all" xmlns:db="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Markdown conversion process.
    
    It groups lines that belong together into a single paragraph. Takes care of code listings.
    Then interprets the result for being anything special (like headers, list entries, etc.) and handles this accordingly.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-handle-paras" on-no-match="shallow-copy"/>

  <xsl:variable name="code-block-marker" as="xs:string" select="'```'"/>
  <xsl:variable name="horizontal-rule-marker" as="xs:string" select="'==='"/>
  <xsl:variable name="header-marker" as="xs:string" select="'#'"/>

  <!-- ================================================================== -->

  <xsl:template match="xdoc:MARKDOWN">
    <xsl:copy copy-namespaces="false">
      <xsl:copy-of select="@*"/>

      <xsl:iterate select="db:line">
        <xsl:param name="in-grouping" as="xs:boolean" select="false()"/>
        <xsl:param name="group" as="element(db:line)*" select="()"/>

        <!-- Make sure that in the unlikely event there's still a group going on when we finish this is output as well. -->
        <xsl:on-completion>
          <xsl:if test="$in-grouping">
            <xsl:call-template name="output-group">
              <xsl:with-param name="line-group" select="$group"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:on-completion>

        <xsl:variable name="line" as="element(db:line)" select="."/>
        <xsl:variable name="line-text" as="xs:string" select="string($line)"/>
        <xsl:variable name="line-is-empty" as="xs:boolean" select="$line-text eq ''"/>
        <xsl:variable name="line-is-code-block-marker" as="xs:boolean" select="starts-with($line-text, $code-block-marker)"/>
        <xsl:variable name="line-is-horizontal-rule-marker" as="xs:boolean" select="starts-with($line-text, $horizontal-rule-marker)"/>
        <xsl:variable name="line-is-header" as="xs:boolean" select="starts-with($line-text, $header-marker)"/>
        <xsl:variable name="line-starts-list-entry" as="xs:boolean" select="matches($line-text, '^[0-9]\.\s+|-\s+')"/>

        <xsl:choose>
          <!-- When we find a horizontal rule marker or header, this ends the current group and is output on its own: -->
          <xsl:when test="$line-is-horizontal-rule-marker or $line-is-header">
            <xsl:if test="$in-grouping">
              <xsl:call-template name="output-group">
                <xsl:with-param name="line-group" select="$group"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="output-group">
              <xsl:with-param name="line-group" select="$line"/>
            </xsl:call-template>
            <xsl:next-iteration>
              <xsl:with-param name="in-grouping" select="false()"/>
              <xsl:with-param name="group" select="()"/>
            </xsl:next-iteration>
          </xsl:when>
          <!-- If we're not grouping yet, every non-empty line starts a group: -->
          <xsl:when test="not($in-grouping) and not($line-is-empty)">
            <xsl:next-iteration>
              <xsl:with-param name="in-grouping" select="true()"/>
              <xsl:with-param name="group" select="."/>
            </xsl:next-iteration>
          </xsl:when>
          <!-- We're grouping and found a line that starts something special (header, list). Output the collected group and start a new one: -->
          <xsl:when test="$in-grouping and $line-starts-list-entry">
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

  <!-- ================================================================== -->
  <!-- OUTPUT A GROUP OF LINES AS A SINGLE PARA AND INTERPRET IT: -->

  <xsl:template name="output-group">
    <xsl:param name="line-group" as="element(db:line)+" required="yes"/>

    <xsl:variable name="is-code-block" as="xs:boolean" select="starts-with(string($line-group[1]), $code-block-marker)"/>
    <xsl:choose>

      <!-- Special handling for code blocks: -->
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
        <programlisting>
          <xsl:value-of select="string-join($line-texts, '&#10;')"/>
        </programlisting>
      </xsl:when>

      <!-- Join other lines together in a single para and inspect this further: -->
      <xsl:otherwise>
        <xsl:variable name="joined-para" as="element(db:para)">
          <para>
            <xsl:copy-of select="$line-group[1]/@indent"/>
            <xsl:value-of select="string-join($line-group/string(), ' ')"/>
          </para>
        </xsl:variable>
        <xsl:apply-templates select="$joined-para" mode="mode-handle-paras"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:para/@indent" mode="mode-handle-paras">
    <!-- Removes no longer necessary @indent -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:para[starts-with(., '===')]" mode="mode-handle-paras">
    <para role="horizontal-rule"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:para[starts-with(., '#')]" mode="mode-handle-paras">
    <bridgehead role="{'header' || local:count-start-pounds(.)}">{ replace(., '^#+\s*', '') }</bridgehead>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:variable name="regexp-list-entry" as="xs:string" select="'^-\s+|^[0-9]\.\s+'"/>
  <xsl:template match="db:para[matches(., $regexp-list-entry)]" mode="mode-handle-paras">
    <xsl:variable name="indent" as="xs:integer" select="xs:integer(@indent)"/>
    <xsl:variable name="listlevel" as="xs:integer" select="floor($indent div 2)"/>
    <xsl:variable name="listtype" as="xs:string" select="if (starts-with(., '-')) then 'itemizedlist' else 'orderedlist'"/>
    <para listlevel="{$listlevel}" listtype="{$listtype}">{ replace(., $regexp-list-entry, '') }</para>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:function name="local:count-start-pounds" as="xs:integer">
    <xsl:param name="text" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="($text eq '')">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:when test="substring($text, 1, 1) eq '#'">
        <xsl:sequence select="local:count-start-pounds(substring($text, 2)) + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

</xsl:stylesheet>
