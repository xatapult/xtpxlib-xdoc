<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.lvc_d53_h3b"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:db="http://docbook.org/ns/docbook"  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Substitutes parameter references test nodes and attributes.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/xdoclib.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-parameters" as="xs:string?" required="yes"/>
  <xsl:param name="parameter-filters-map" as="map(xs:string, xs:string)" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL VARIABLES: -->

  <xsl:variable name="parameters" as="map(xs:string, xs:string*)"
    select="xdoc:parameters-get-with-filtermap($href-parameters, $parameter-filters-map)"/>
  
  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="text()[contains(., $xtlc:parameter-main-trigger-character)]">
    <xsl:value-of select="xtlc:expand-text-against-parameters(., $parameters)"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="@*[contains(., $xtlc:parameter-main-trigger-character)]">
    <xsl:attribute name="{name(.)}" select="xtlc:expand-text-against-parameters(., $parameters)"/>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template match="db:annoying-warning-suppression-template"/>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="*">
    <!-- For a for me completely unknown reason, there must be an identity template in this stylesheet to make
         it work together with XProc. Otherwise I get:
    
         Error '{http://www.w3.org/2005/xqt-errors}XTDE0440': Cannot output a namespace node for the default namespace (http://docbook.org/ns/docbook) 
         when the element is in no namespace.
         
         Bug somewhere in Saxon or Morgana? Hard to reproduce on a smaller scale.
    -->
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
