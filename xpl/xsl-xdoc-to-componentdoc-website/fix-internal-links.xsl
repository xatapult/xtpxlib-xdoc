<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local-xdoc-to-moduledoc-website" xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all">
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

  <xsl:variable name="original-document" as="document-node()" select="/"/>

  <xsl:variable name="id-index-name" as="xs:string" select="'id-index'" static="true"/>
  <xsl:key _name="{$id-index-name}" match="xhtml:*" use="@id"/>

  <!-- ================================================================== -->

  <xsl:template match="xhtml:a[starts-with(@href, '#')]">

    <xsl:variable name="current-element" as="element(xhtml:a)" select="."/>
    <xsl:variable name="id" as="xs:string" select="substring-after($current-element/@href, '#')"/>
    <xsl:variable name="referred-elm" as="element()?" select="key($id-index-name, $id, $original-document)[1]"/>
    <xsl:variable name="referred-elm-document-elm" as="element(xtlcon:document)?" select="$referred-elm/ancestor::xtlcon:document"/>
    
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="exists($referred-elm)">
        <!-- If the referrer and referred have the same container document element as root, all is ok. If not we have to patch things up: -->
        <xsl:if test="not($referred-elm-document-elm is $current-element/ancestor::xtlcon:document)"> 
          <xsl:attribute name="href" select="$referred-elm-document-elm/@href-target || $current-element/@href"/>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
