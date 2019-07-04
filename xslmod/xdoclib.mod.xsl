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
      <!--~ String with filter parameters in name|value|name|value|... format. -->
    </xsl:param>

    <!-- Process the filterstring into an appropriate map: -->
    <xsl:variable name="filterstring-parts" as="xs:string*" select="tokenize($filterstring, '\|')"/>
    <xsl:variable name="filtermap" as="map(xs:string, xs:string*)">
      <xsl:map>
        <xsl:for-each select="1 to count($filterstring-parts)">
          <xsl:variable name="pos" as="xs:integer" select="."/>
          <xsl:variable name="is-name" as="xs:boolean" select="(($pos mod 2) eq 1)"/>
          <xsl:if test="$is-name">
            <xsl:map-entry key="normalize-space($filterstring-parts[$pos])" select="normalize-space($filterstring-parts[$pos + 1])"/>
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
        <xsl:map-entry key="'HREF-SOURCE'" select="xtlc:href-canonical(base-uri($local:root-element))"/>
        <xsl:map-entry key="'HREF-PARAMETERS'" select="xtlc:href-canonical($href-parameters)"/>
      </xsl:map>
    </xsl:variable>

    <!-- Process the parameters with these filters and merge the special values in: -->
    <xsl:sequence select="map:merge(($special-values-map, xtlc:parameters-get($href-parameters, $filtermap)))"/>

  </xsl:function>
  
</xsl:stylesheet>
