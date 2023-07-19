<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.zkx_5pg_3jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" exclude-result-prefixes="#all" xmlns:db="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Markdown conversion process.
    
    Takes care of the proper nesting of lists
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->

  <xsl:template match="xdoc:MARKDOWN">
    <xsl:copy copy-namespaces="false">
      <xsl:copy-of select="@*"/>

      <xsl:for-each-group select="*" group-adjacent="exists(self::db:para) and exists(@listtype) and exists(@listlevel)">
        <xsl:choose>

          <!-- Group of list paras: -->
          <xsl:when test="current-grouping-key()">
            <!-- We'll handle everything from the outside in, so we go for the deepest nested levels first. -->
            <xsl:variable name="maximum-list-level" as="xs:integer"
              select="max(for $listpara in current-group() return xs:integer($listpara/@listlevel))"/>
              <xsl:call-template name="handle-list">
                <xsl:with-param name="current-listlevel" select="$maximum-list-level"/>
                <xsl:with-param name="contents" select="current-group()"/>
              </xsl:call-template>
          </xsl:when>

          <!-- Non-list paras: -->
          <xsl:otherwise>
            <xsl:copy-of select="current-group()" copy-namespaces="false"/>
          </xsl:otherwise>

        </xsl:choose>
      </xsl:for-each-group>

    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template name="handle-list">
    <xsl:param name="current-listlevel" as="xs:integer" required="yes"/>
    <xsl:param name="contents" as="element()+" required="yes"/>

    <xsl:variable name="new-contents" as="element()+">
      <!-- Group together paras with the indicated listlevel: -->
      <xsl:for-each-group select="$contents" group-adjacent="empty(@listlevel) or (xs:integer(@listlevel) eq $current-listlevel)">
        <xsl:choose>

          <!-- We have paras with the indicated list level. Now we still have to group these by list type: -->
          <xsl:when test="current-grouping-key()">
            <xsl:for-each-group select="current-group()" group-adjacent="local:get-listtype(.)">
              <xsl:element name="{current-grouping-key()}">
                <xsl:for-each select="current-group()">
                  <listitem>
                    <xsl:sequence select="." />
                  </listitem>
                </xsl:for-each>
              </xsl:element>
            </xsl:for-each-group>
          </xsl:when>

          <!-- Other paras (or nested lists), just copy: -->
          <xsl:otherwise>
            <xsl:sequence select="current-group()" />
          </xsl:otherwise>

        </xsl:choose>
      </xsl:for-each-group>
    </xsl:variable>

    <!-- Recursively handle all encompassing list levels: -->
    <xsl:choose>
      <xsl:when test="$current-listlevel gt 0">
        <xsl:call-template name="handle-list">
          <xsl:with-param name="current-listlevel" select="$current-listlevel - 1"/>
          <xsl:with-param name="contents" select="$new-contents"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$new-contents"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:get-listtype" as="xs:string">
    <!-- Gets the list type (orderedlist or itemizedlist) of the current element. -->
    <xsl:param name="elm" as="element()?"/>
    
    <xsl:variable name="listtype" as="xs:string?" select="$elm/@listtype"/>
    <xsl:choose>
      <!-- Should not happen but assume itemizedlist: -->
      <xsl:when test="empty($elm)">
        <xsl:sequence select="'itemizedlist'"/>
      </xsl:when>
      <!-- When there is no listtype indicator, look at its predecessor: -->
      <xsl:when test="empty($listtype)">
        <xsl:sequence select="local:get-listtype($elm/preceding-sibling::*[last()])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$listtype"/>
      </xsl:otherwise>  
    </xsl:choose>
    
  </xsl:function>
  
</xsl:stylesheet>
