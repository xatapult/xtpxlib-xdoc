<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.wbh_ks3_h3b"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--	
       Library with XSLT code for internal usage in the xdoc component.
       
       Includes all the regular and necessary xtpxlib-common libraries.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:include href="../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../xtpxlib-common/xslmod/parameters.mod.xsl"/>
  <xsl:include href="../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:variable name="local:root-element" as="element()" select="/*"/>

  <!-- ================================================================== -->

  <xsl:function name="xdoc:parameters-get-with-filterstring" as="map(xs:string, xs:string*)">
    <!-- Gets the parameters and applies a filterstring setting. Also sets some special values. -->
    <xsl:param name="href-parameters" as="xs:string">
      <!--~ Reference to the parameter file. -->
    </xsl:param>
    <xsl:param name="filterstring" as="xs:string">
      <!--~ String with filter parameters in name=value|name=value|... format. -->
    </xsl:param>

    <!-- Process the filterstring into an appropriate map: -->
    <xsl:variable name="filterstring-parts" as="xs:string*" select="tokenize($filterstring, '\|')"/>
    <xsl:variable name="filtermap" as="map(xs:string, xs:string*)">
      <xsl:map>
        <xsl:for-each select="$filterstring-parts">
          <xsl:variable name="filter-name" as="xs:string" select="normalize-space(substring-before(., '='))"/>
          <xsl:variable name="filter-value" as="xs:string" select="string(substring-after(., '='))"/>
          <xsl:if test="$filter-name ne ''">
            <xsl:map-entry key="$filter-name" select="$filter-value"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:map>
    </xsl:variable>

    <!-- Create some special parameters: -->
    <xsl:variable name="special-values-map" as="map(xs:string, xs:string*)">
      <xsl:map>
        <xsl:map-entry key="'DATETIME'" select="format-dateTime(current-dateTime(), '[Y]-[M01]-[D01] [H01]:[m01]:[s01]')"/>
        <xsl:map-entry key="'DATE'" select="format-dateTime(current-dateTime(), '[Y]-[M01]-[D01]')"/>
        <xsl:map-entry key="'TIME'" select="format-dateTime(current-dateTime(), '[H01]:[m01]:[s01]')"/>
        <xsl:map-entry key="'HREF-SOURCE'" select="xtlc:href-protocol-remove(xtlc:href-canonical(base-uri($local:root-element)))"/>
      </xsl:map>
    </xsl:variable>

    <!-- Check for the existence of the parameter file: -->
    <xsl:variable name="href-parameters-canonical" as="xs:string" select="xtlc:href-canonical($href-parameters)"/>
    <xsl:if test="not(doc-available($href-parameters-canonical))">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('Parameters file ', xtlc:q($href-parameters-canonical), ' not found or not well-formed')"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Process the parameters with these filters and merge the special values in: -->
    <xsl:sequence select="map:merge(($special-values-map, xtlc:parameters-get($href-parameters-canonical, $filtermap)))"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xdoc:fixed-width-characters-per-cm-dbl" as="xs:double">
    <!-- Computes the number of fixed-width characters based on the main font size (based on using FOP) -->
    <xsl:param name="main-font-size-dbl" as="xs:double"/>
    <xsl:sequence select="5.55 + ((10 - $main-font-size-dbl) * 0.45) "/>
  </xsl:function>

</xsl:stylesheet>
