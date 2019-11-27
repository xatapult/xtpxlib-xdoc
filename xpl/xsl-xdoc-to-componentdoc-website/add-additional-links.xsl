<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local-xdoc-to-moduledoc-website" xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*	
    TBD
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="pdf-href" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="href-index-document" as="xs:string" select="/*/xtlcon:document[xs:boolean(@index)]/@href-target"/>
  <xsl:variable name="title" as="xs:string" select="/*/@title"/>

  <xsl:variable name="toc" as="element(xhtml:div)">
    <xsl:call-template name="create-toc"/>
  </xsl:variable>

  <!-- ================================================================== -->

  <xsl:template match="xtlcon:document//xhtml:body">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:comment> == START TOC == </xsl:comment>
      <xsl:copy-of select="$toc"/>
      <xsl:comment> == END TOC == </xsl:comment>
      <xsl:copy-of select="node()"/>

    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template name="create-toc">

    <div class="toc">
      <h1 class="toc-header">{$title}</h1>
      <xsl:where-populated>
        <ul class="toc-level-0">
          <li>
            <a href="{$href-index-document}">home</a>
          </li>
          <xsl:for-each select="/*/xtlcon:document[not(xs:boolean(@index))]">
            <xsl:variable name="href" as="xs:string" select="@href-target"/>
            <li>
              <a href="{$href}">
                <xsl:value-of select="@title"/>
              </a>
              <xsl:call-template name="add-toc-level">
                <xsl:with-param name="href" select="$href"/>
                <xsl:with-param name="root" select="(.//xhtml:body)[1]"/>
              </xsl:call-template>
            </li>
          </xsl:for-each>
          <li>
            <a href="{$pdf-href}">PDF</a>
          </li>
        </ul>
      </xsl:where-populated>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-toc-level">
    <xsl:param name="href" as="xs:string" required="yes"/>
    <xsl:param name="root" as="element()" required="no" select="."/>
    <xsl:param name="level" as="xs:integer" required="no" select="1"/>

    <xsl:where-populated>
      <ul class="toc-level-{$level}">
        <xsl:variable name="section-class" as="xs:string" select="'sect' || $level"/>
        <xsl:for-each select="$root//xhtml:div[@class eq $section-class]">
          <xsl:variable name="header-element-name" as="xs:string" select="'h' || ($level + 1)"/>
          <xsl:variable name="title-elm" as="element()?" select="(.//xhtml:*[local-name() eq $header-element-name])[1]"/>
          <li>
            <a href="{$href}#{@id}">
              <xsl:value-of select="string($title-elm)"/>
            </a>
            <xsl:if test="$level lt 3">
              <xsl:call-template name="add-toc-level">
                <xsl:with-param name="href" select="$href"/>
                <xsl:with-param name="level" select="$level + 1"/>
              </xsl:call-template>
            </xsl:if>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:where-populated>
  </xsl:template>

</xsl:stylesheet>
