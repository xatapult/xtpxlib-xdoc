<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.zkx_5pg_3jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" exclude-result-prefixes="#all" xmlns:db="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Markdown conversion process.
    
    It handles all the inline coding in the simple Markdown, like `code`, *italic*, etc.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->

  <xsl:template match="xdoc:MARKDOWN/db:*[string(.) ne '']">
    <xsl:copy copy-namespaces="false">
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="process-text-1">
        <xsl:with-param name="text" select="string(.)"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="process-text-1" as="node()*">
    <!-- Takes care of anything wrapped in stars (*italic*, **bod** and ***italic-and-bold***). Then passes the remaining string on for
      further checks.-->
    <xsl:param name="text" as="xs:string" required="yes"/>

    <xsl:analyze-string select="$text" regex="\*+[^*]+?\*+">

      <xsl:matching-substring>
        <!-- Find out how many stars there are at the end and the beginning and try to sort out all kinds of weird combinations... 
          Make sure when there are too many stars at the beginning and/or the end, these do not disappear.
        -->
        <xsl:variable name="starting-stars" as="xs:integer" select="local:starting-stars(.)"/>
        <xsl:variable name="ending-stars" as="xs:integer" select="local:ending-stars(.)"/>
        <xsl:variable name="minimum-stars" as="xs:integer" select="min(($starting-stars, $ending-stars))"/>
        <xsl:variable name="effective-stars" as="xs:integer" select="if ($minimum-stars gt 3) then 3 else $minimum-stars"/>
        <xsl:variable name="text-no-stars" as="xs:string"
          select="substring(., $starting-stars + 1, string-length(.) - $starting-stars - $ending-stars)"/>
        <xsl:for-each select="1 to ($starting-stars - $effective-stars)">
          <xsl:value-of select="'*'"/>
        </xsl:for-each>
        <xsl:choose>
          <xsl:when test="$effective-stars eq 1">
            <emphasis role="italic">
              <xsl:call-template name="process-text-2">
                <xsl:with-param name="text" select="$text-no-stars"/>
              </xsl:call-template>
            </emphasis>
          </xsl:when>
          <xsl:when test="$effective-stars eq 2">
            <emphasis role="bold">
              <xsl:call-template name="process-text-2">
                <xsl:with-param name="text" select="$text-no-stars"/>
              </xsl:call-template>
            </emphasis>
          </xsl:when>
          <xsl:otherwise>
            <emphasis role="italic">
              <emphasis role="bold">
                <xsl:call-template name="process-text-2">
                  <xsl:with-param name="text" select="$text-no-stars"/>
                </xsl:call-template>
              </emphasis>
            </emphasis>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="1 to ($ending-stars - $effective-stars)">
          <xsl:value-of select="'*'"/>
        </xsl:for-each>
      </xsl:matching-substring>

      <xsl:non-matching-substring>
        <xsl:call-template name="process-text-2">
          <xsl:with-param name="text" select="."/>
        </xsl:call-template>
      </xsl:non-matching-substring>

    </xsl:analyze-string>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="process-text-2" as="node()*">
    <!-- Checks for `code` markers and then passes the remaining texts on for further processing. -->
    <xsl:param name="text" as="xs:string" required="yes"/>

    <xsl:analyze-string select="$text" regex="`[^`]*?`">

      <xsl:matching-substring>
        <code>
          <xsl:call-template name="process-text-3">
            <xsl:with-param name="text" select="substring(., 2, string-length(.) - 2)"/>
          </xsl:call-template>
        </code>
      </xsl:matching-substring>

      <xsl:non-matching-substring>
        <xsl:call-template name="process-text-3">
          <xsl:with-param name="text" select="."/>
        </xsl:call-template>
      </xsl:non-matching-substring>

    </xsl:analyze-string>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="process-text-3" as="node()*">
    <!-- Processes links [link-text](http://...) constructions. If the link starts with a * it is assumed to be an internal link. -->
    <xsl:param name="text" as="xs:string" required="yes"/>
    
    <xsl:variable name="internal-link-marker" as="xs:string" select="'*'"/>

    <xsl:analyze-string select="$text" regex="\[(.+?)\]\((.+?)\)">

      <xsl:matching-substring>
        <xsl:variable name="link-text" as="xs:string" select="regex-group(1)"/>
        <xsl:variable name="link-href" as="xs:string" select="regex-group(2)"/>
        <xsl:choose>
          <xsl:when test="starts-with($link-href, $internal-link-marker)">
            <link linkend="{substring-after($link-href, $internal-link-marker)}">{$link-text}</link>
          </xsl:when>
          <xsl:otherwise>
            <link xlink:href="{$link-href}">{$link-text}</link>
          </xsl:otherwise>  
        </xsl:choose>
      </xsl:matching-substring>

      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>

    </xsl:analyze-string>

  </xsl:template>

  <!-- ================================================================== -->

  <xsl:function name="local:starting-stars" as="xs:integer">
    <xsl:param name="text" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="($text eq '')">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:when test="substring($text, 1, 1) eq '*'">
        <xsl:sequence select="local:starting-stars(substring($text, 2)) + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:ending-stars" as="xs:integer">
    <xsl:param name="text" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="($text eq '')">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:when test="substring($text, string-length($text), 1) eq '*'">
        <xsl:sequence select="local:ending-stars(substring($text, 1, string-length($text) - 1)) + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xdoc:warning-suppression-template"/>

</xsl:stylesheet>
