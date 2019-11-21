<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.k4s_cdm_5jb"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       TBD
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../../xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-parameters" as="xs:string" required="yes"/>
  <xsl:param name="href-global-parameters" as="xs:string" required="yes"/>
  <xsl:param name="href-version-information" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="parameters-document" as="document-node()">
    <xsl:choose>
      <xsl:when test="normalize-space($href-parameters) ne ''">
        <xsl:if test="not(doc-available($href-parameters))">
          <xsl:call-template name="xtlc:raise-error">
            <xsl:with-param name="msg-parts" select="('Parameters document for merge with version information not found: ', xtlc:q($href-parameters))"
            />
          </xsl:call-template>
        </xsl:if>
        <xsl:sequence select="doc($href-parameters)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:document>
          <parameters>
            <xsl:comment> == Generated parameters document by merge-parameters-and-version-information.xsl - {current-dateTime()} == </xsl:comment>
          </parameters>
        </xsl:document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="global-parameters-document" as="document-node()?" >
    <xsl:choose>
      <xsl:when test="normalize-space($href-global-parameters) ne ''">
        <xsl:if test="not(doc-available($href-global-parameters))">
          <xsl:call-template name="xtlc:raise-error">
            <xsl:with-param name="msg-parts" select="('Global parameters document not found: ', xtlc:q($href-global-parameters))"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:sequence select="doc($href-global-parameters)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="version-information-document" as="document-node()?">
    <xsl:choose>
      <xsl:when test="normalize-space($href-version-information) ne ''">
        <xsl:if test="not(doc-available($href-version-information))">
          <xsl:call-template name="xtlc:raise-error">
            <xsl:with-param name="msg-parts" select="('Version information document not found: ', xtlc:q($href-version-information))"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:sequence select="doc($href-version-information)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">
    <xsl:apply-templates select="$parameters-document/*"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*:parameters">
    <xsl:copy copy-namespaces="false">
      <xsl:copy-of select="@* | node()"/>
      <xsl:if test="exists($version-information-document)">
        <xsl:comment> == Generated version information parameters by merge-parameters-and-version-information.xsl - {current-dateTime()} == </xsl:comment>
        <xsl:comment> == Source: { xtlc:q($href-version-information) } == </xsl:comment>
        <xsl:call-template name="generate-version-parameters"/>
      </xsl:if>
      <xsl:copy-of select="$global-parameters-document//*:parameters/*:parameter"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template name="generate-version-parameters" as="element(parameter)*">
    <xsl:for-each select="$version-information-document/*">
      <!-- Basic information: -->
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-name'"/>
        <xsl:with-param name="value" select="@component-name"/>
      </xsl:call-template>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'git-uri'"/>
        <xsl:with-param name="value" select="@git-uri"/>
      </xsl:call-template>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="value-must-exist" select="false()"/>
        <xsl:with-param name="name" select="'github-pages-uri'"/>
        <xsl:with-param name="value" select="@github-pages-uri"/>
      </xsl:call-template>
      <!-- Current release: -->
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'current-release-version'"/>
        <xsl:with-param name="value" select="xtlc:release[1]/@version"/>
      </xsl:call-template>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'current-release-date'"/>
        <xsl:with-param name="value" select="xtlc:release[1]/@date"/>
      </xsl:call-template>
      <!-- Dependencies: -->
      <xsl:variable name="dependencies" as="xs:string*" select="xtlc:dependencies/xtlc:component/@name/string()"/>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-dependencies'"/>
        <xsl:with-param name="value" select="if (empty($dependencies)) then '(none)' else string-join($dependencies, ' ')"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-parameter" as="element(parameter)?">
    <xsl:param name="name" as="xs:string" required="yes"/>
    <xsl:param name="value" as="xs:string?" required="yes"/>
    <xsl:param name="value-must-exist" as="xs:boolean" required="false" select="true()"/>

    <xsl:variable name="value-is-empty" as="xs:boolean" select="normalize-space($value) eq ''"/>
    <xsl:if test="$value-must-exist and $value-is-empty">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts"
          select="('Version information for parameter ', xtlc:q($name), ' is missing from ', xtlc:q($href-version-information))"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not($value-is-empty)">
      <parameter name="{$name}">
        <value>{ $value }</value>
      </parameter>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
