<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:local="#local-u67gh"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true"
  xmlns="http://docbook.org/ns/docbook">
  <!-- ================================================================== -->
  <!--~
    Creates a the input XML for code-docgen for a single file.
    
    Main input is the document that originally started code-docgen-dir. We need this because we have to 
    get its attributes on the output.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-file" as="xs:string" required="yes">
    <!-- Href of the document to process -->
  </xsl:param>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xdoc:transform href="$xdoc/code-docgen.xpl"> 
      <xsl:copy-of select="/*/@*"/>
      <xsl:attribute name="xml:base" select="$href-file"/>
      <xsl:copy-of select="doc($href-file)/*"/>
    </xdoc:transform>
  </xsl:template>

</xsl:stylesheet>
