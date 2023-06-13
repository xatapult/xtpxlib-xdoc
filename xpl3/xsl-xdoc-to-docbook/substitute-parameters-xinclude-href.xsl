<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.lvc_d53_h3b"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Substitutes parameter references in xi:include/@href attributes. 
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/xdoclib.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-parameters" as="xs:string" required="yes"/>
  <xsl:param name="parameter-filters-map" as="map(xs:string, xs:string)" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL VARIABLES: -->

  <xsl:variable name="parameters" as="map(xs:string, xs:string*)" select="xdoc:parameters-get-with-filtermap($href-parameters, $parameter-filters-map)"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="xi:include[contains(@href, $xtlc:parameter-main-trigger-character)]">
    <xsl:copy>
      <xsl:copy-of select="@* except @href"/>
      <xsl:attribute name="href" select="xtlc:expand-text-against-parameters(@href, $parameters)"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template match="db:annoying-warning-suppression-template"/>

</xsl:stylesheet>
