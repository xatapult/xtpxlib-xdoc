<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:local="#local-u67gh"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true" xmlns="http://docbook.org/ns/docbook">
  <!-- ================================================================== -->
  <!--~
    Shared code for creating documentation (used also by the code-docgen-dir transform).
  -->
  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="element-documentation-start" as="xs:string" select="'~'">
    <!-- A comment that starts with this string is considered the description for its parent element. -->
  </xsl:variable>

  <!-- ================================================================== -->

  <xsl:template name="get-element-documentation">
    <!-- Tries to find the documentation comment for this element (a documentation comment starts with the string $element-documentation-start)
      and extracts this into an <xdoc:MARKDOWN> element. -->
    <xsl:param name="parent-elm" as="element()" required="no" select="."/>
    <xsl:param name="header-only" as="xs:boolean" required="false" select="false()"/>

    <xsl:variable name="documentation-comment" as="comment()?"
      select="$parent-elm/comment()[starts-with(., $element-documentation-start)]
      [normalize-space(substring-after(., $element-documentation-start)) ne '']"/>
    <xsl:if test="exists($documentation-comment)">
      <xdoc:MARKDOWN header-only="{$header-only}">{ substring-after($documentation-comment, $element-documentation-start) }</xdoc:MARKDOWN>
    </xsl:if>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template name="xpl-get-element-documentation">
    <xsl:param name="parent-elm" as="element()" required="no" select="."/>
    <xsl:param name="header-only" as="xs:boolean" required="no" select="false()"/>
    
    <xsl:variable name="elm-documentation" as="element(p:documentation)?" select="($parent-elm/p:documentation[normalize-space(.) ne ''])[1]"/>
    <xsl:if test="exists($elm-documentation)">
      <xdoc:MARKDOWN header-only="{$header-only}">{ string($elm-documentation) }</xdoc:MARKDOWN>
    </xsl:if>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template name="xsd-get-element-documentation">
    <xsl:param name="parent-elm" as="element()" required="no" select="."/>
    <xsl:param name="header-only" as="xs:boolean" required="no" select="false()"/>
    
    <xsl:variable name="elm-documentation" as="element(xs:documentation)?"
      select="($parent-elm/xs:annotation/xs:documentation[normalize-space(.) ne ''])[1]"/>
    <xsl:if test="exists($elm-documentation)">
      <xdoc:MARKDOWN header-only="{$header-only}">{ string($elm-documentation) }</xdoc:MARKDOWN>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
