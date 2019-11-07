<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local-xdoc-to-moduledoc-website" xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    TBD
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <xsl:mode on-no-match="shallow-copy"/>

<!-- ================================================================== -->
  <!-- PARAMETERS -->
  
  <xsl:param name="resources-target-subdirectory" as="xs:string" required="yes"/>
  
  <!-- ================================================================== -->

  <xsl:template match="c:directory">
    <xsl:comment> == RESOURCES START == </xsl:comment>
    <xsl:for-each select="c:file">
      <xtlcon:external-document href-source="{@href-abs}" href-target="{xtlc:href-concat(($resources-target-subdirectory, @href-rel))}"/>
    </xsl:for-each>
    <xsl:comment> == RESOURCES END == </xsl:comment>
  </xsl:template>

</xsl:stylesheet>
