<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.lvc_d53_h3b"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Processes the @href attribute of an <xdoc:transform> element into a full absolute reference
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/xdoclib.mod.xsl"/>

  <xsl:variable name="xdoc-indicator" as="xs:string" select="'$xdoc/'"/>

  <!-- ================================================================== -->

  <xsl:template match="xdoc:transform/@href[not(xtlc:href-is-absolute(.))]">

    <!-- Get an absolute path to the required transformation file: -->
    <xsl:variable name="path-normalized" as="xs:string" select="normalize-space(.) => translate('\', '/')"/>
    <xsl:variable name="path-is-xdoc" as="xs:boolean" select="starts-with($path-normalized, $xdoc-indicator)"/>
    <xsl:variable name="path-normalized-name" as="xs:string"
      select="if ($path-is-xdoc) then substring-after($path-normalized, $xdoc-indicator) else $path-normalized"/>

    <xsl:variable name="root-path" as="xs:string">
      <xsl:choose>
        <xsl:when test="$path-is-xdoc">
          <xsl:sequence select="resolve-uri('../../transforms3/', static-base-uri())"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="string(base-uri()) => xtlc:href-path()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="absolute-path-to-transform" as="xs:string"
      select="xtlc:href-concat(($root-path, $path-normalized-name)) => xtlc:href-canonical()"/>

    <!-- Find out whether it exists and what it is: -->
    <!-- Remark: Now this is simple. we just look at the file extension. Might become more complex in the future. -->
    <xsl:if test="not(doc-available($absolute-path-to-transform))">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('xdoc transformation not found: ', xtlc:q($absolute-path-to-transform))"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="transformation-extension" as="xs:string" select="xtlc:href-ext($absolute-path-to-transform)"/>
    <xsl:variable name="transformation-type" as="xs:string">
      <xsl:choose>
        <xsl:when test="$transformation-extension eq 'xpl'">
          <!-- Check whether the transformation is actually XProc 3.0 (and not 1.0 as it might be for historic reasons): -->
          <xsl:if test="normalize-space(doc($absolute-path-to-transform)/*/@version) ne '3.0'">
            <xsl:call-template name="xtlc:raise-error">
              <xsl:with-param name="msg-parts" select="('XProc pipeline is not version 3.0: ', xtlc:q($absolute-path-to-transform))"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:sequence select="'xproc3'"/>
        </xsl:when>
        <xsl:when test="$transformation-extension = ('xsl', 'xslt')">
          <xsl:sequence select="'xslt'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="xtlc:raise-error">
            <xsl:with-param name="msg-parts" select="'Could not determine transformation type for ', xtlc:q($absolute-path-to-transform)"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Record the results: -->
    <xsl:attribute name="href" select="$absolute-path-to-transform"/>
    <xsl:attribute name="xdoc:transformation-type" select="$transformation-type"/>

  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template match="db:annoying-warning-suppression-template"/>
  <xsl:template match="xdoc:annoying-warning-suppression-template"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="*">
    <!-- For a for me completely unknown reason, there must be an identity template in this stylesheet to make
         it work together with XProc. Otherwise I get:
    
         Error '{http://www.w3.org/2005/xqt-errors}XTDE0440': Cannot output a namespace node for the default namespace (http://docbook.org/ns/docbook) 
         when the element is in no namespace.
         
         Bug somewhere in Saxon or Morgana? Hard to reproduce on a smaller scale.
    -->
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"></xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
