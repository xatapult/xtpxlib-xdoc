<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local-xdoc-to-moduledoc-website" xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    TBD
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>

  <xsl:mode on-no-match="fail"/>
  <xsl:mode name="mode-create-contents" on-no-match="shallow-copy"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-target-path" as="xs:string" required="yes"/>
  <xsl:param name="href-componentdoc-website-template" as="xs:string" required="yes"/>
  <xsl:param name="component-name" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="template" as="document-node()">
    <xsl:choose>
      <xsl:when test="doc-available($href-componentdoc-website-template)">
        <xsl:sequence select="doc($href-componentdoc-website-template)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts"
            select="('Module documentation website template ', xtlc:q($href-componentdoc-website-template), ' not found')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ================================================================== -->

  <xsl:template match="/">

    <!-- Generate a title for this site: -->
    <xsl:variable name="title" as="xs:string" select="(/*/xhtml:div[@class eq 'header']/xhtml:*[@class eq 'title'])[1]"/>
    <xsl:variable name="subtitle" as="xs:string?" select="(/*/xhtml:div[@class eq 'header']/xhtml:*[@class eq 'subtitle'])[1]"/>
    <xsl:variable name="full-title" as="xs:string" select="string-join(($title, $subtitle), ' - ')"/>

    <!-- Create the container: -->
    <xtlcon:document-container timestamp="{current-dateTime()}" href-target-path="{$href-target-path}"
      moduledoc-website-template="{$href-componentdoc-website-template}" title="{$full-title}" component-name="{$component-name}">
      <xsl:for-each select="/*/xhtml:div[@class = ('preface', 'chapter', 'appendix')]">
        <xsl:variable name="is-preface" as="xs:boolean" select="@class eq 'preface'"/>
        <!-- Create a container document entry: -->
        <xsl:variable name="title" as="xs:string" select="local:get-title(.)"/>
        <xtlcon:document title="{$title}" index="{$is-preface}">
          <xsl:choose>
            <xsl:when test="$is-preface">
              <xsl:attribute name="href-target" select="'index.html'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="href-target" select="local:title-to-id($title) || '.html'"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- Add the contents, wrapped in the template: -->
          <xsl:apply-templates select="$template" mode="mode-create-contents">
            <xsl:with-param name="title" as="xs:string" select="$title" tunnel="true"/>
            <xsl:with-param name="body" as="element()" select="." tunnel="true"/>
          </xsl:apply-templates>
        </xtlcon:document>
      </xsl:for-each>
    </xtlcon:document-container>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- TEMPLATE HANDLING: -->

  <xsl:template match="xhtml:title" mode="mode-create-contents">
    <xsl:param name="title" as="xs:string" required="yes" tunnel="true"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:value-of select="$title"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:body" mode="mode-create-contents">
    <xsl:param name="body" as="element()" required="yes" tunnel="true"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="$body"/>
      <!-- Also copy anything that was already in the body: -->
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:get-title" as="xs:string">
    <xsl:param name="root" as="element()"/>

    <xsl:variable name="title-h1" as="element(xhtml:h1)?" select="($root//xhtml:h1)[1]"/>
    <xsl:variable name="id" as="xs:string?" select="$root/@id"/>

    <xsl:choose>
      <xsl:when test="exists($title-h1)">
        <xsl:sequence select="string($title-h1)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="($id, generate-id($root))"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:title-to-id" as="xs:string">
    <xsl:param name="title" as="xs:string"/>
    <xsl:sequence select="replace($title, '[^A-Za-z0-9.\-]', '_')"/>
  </xsl:function>

</xsl:stylesheet>
