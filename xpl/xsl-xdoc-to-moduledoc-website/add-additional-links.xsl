<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local-xdoc-to-moduledoc-website" xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    TBD
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="href-index-document" as="xs:string" select="/*/xtlcon:document[xs:boolean(@index)]/@href-target"/>

  <!-- ================================================================== -->

  <xsl:template match="xtlcon:document[not(xs:boolean(@index))]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="href-previous" as="xs:string?" select="preceding-sibling::xtlcon:document[not(xs:boolean(@index))][1]/@href-target"
          tunnel="true"/>
        <xsl:with-param name="href-next" as="xs:string?" select="following-sibling::xtlcon:document[not(xs:boolean(@index))][1]/@href-target"
          tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlcon:document[not(xs:boolean(@index))]//xhtml:body">

    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="add-naviagtion-links">
        <xsl:with-param name="base-class" select="'top-navigation'"/>
      </xsl:call-template>
      <xsl:copy-of select="node()"/>
      <xsl:call-template name="add-naviagtion-links">
        <xsl:with-param name="base-class" select="'bottom-navigation'"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlcon:document[xs:boolean(@index)]//xhtml:body">

    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="node()"/>
      <xsl:call-template name="add-toc"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template name="add-naviagtion-links">
    <xsl:param name="base-class" as="xs:string" required="yes"/>
    <xsl:param name="href-previous" as="xs:string?" required="yes" tunnel="true"/>
    <xsl:param name="href-next" as="xs:string?" required="yes" tunnel="true"/>


    <div class="{$base-class}">
      <p>
        <xsl:choose>
          <xsl:when test="exists($href-previous)">
            <span class="navigation-link enabled">
              <a href="{$href-previous}">previous</a>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <span class="navigation-link disabled"/>
            <xsl:text>previous</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <span class="navigation-link enabled">
          <a href="{$href-index-document}">index</a>
        </span>
        <xsl:text> </xsl:text>
        <xsl:choose>
          <xsl:when test="exists($href-next)">
            <span class="navigation-link enabled">
              <a href="{$href-next}">next</a>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <span class="navigation-link disabled">
              <xsl:text>next</xsl:text>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </div>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-toc">

    <div class="toc">
      <xsl:where-populated>
        <ul class="toc-level-0">
          <xsl:for-each select="/*/xtlcon:document[not(xs:boolean(@index))]">
            <xsl:variable name="href" as="xs:string" select="@href-target"/>
            <li>
              <p>
                <a href="{$href}">
                  <xsl:value-of select="@title"/>
                </a>
              </p>
              <xsl:call-template name="add-toc-level">
                <xsl:with-param name="href" select="$href"/>
                <xsl:with-param name="root" select="(.//xhtml:body)[1]"/>
              </xsl:call-template>
            </li>
          </xsl:for-each>
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
            <p>
              <a href="{$href}#{@id}">
                <xsl:value-of select="string($title-elm)"/>
              </a>
            </p>
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
