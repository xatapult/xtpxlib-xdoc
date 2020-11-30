<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*	
    Prepares the XHTML output of xdoc:docbook-to-xhtml for Print CSS processing
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <!--<xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>-->

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="print-css-processor" as="xs:string" required="yes"/>
  <xsl:param name="href-css" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->
  
  <xsl:template match="/">
    <html>
      <xsl:comment> == Print CSS input file for the {$print-css-processor} processor == </xsl:comment>
      <xsl:comment> == Generated: {current-dateTime()} == </xsl:comment>
      <head>
        <link rel="stylesheet" type="text/css" href="{$href-css}" />
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="@href | @src">
    <xsl:attribute name="{local-name()}" select="resolve-uri(., base-uri(..))"/>
  </xsl:template>
  
</xsl:stylesheet>
