<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.zkx_5pg_3jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" exclude-result-prefixes="#all" xmlns:db="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Markdown conversion process.
    
    Finalizes the list handling by joining nested lists into the previous listitem.
    Also removes no longer needed attributes.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->

  <xsl:template match="xdoc:MARKDOWN//(db:itemizedlist | db:orderedlist)">

    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:for-each-group select="db:listitem" group-adjacent="local:listitem-index(.)">
        <listitem>
          <xsl:apply-templates select="current-group()/*"/>
        </listitem>
      </xsl:for-each-group>
    </xsl:copy>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:listitem-index" as="xs:integer">
    <!-- Computes a suitable index number for a listitem so we can group on this:
         - If it contains a para it's the index of the listitem in the list
         - If not its it means it belongs to the previous listitem. So the index of the previous listitem is retrieved.
    -->
    <xsl:param name="listitem" as="element(db:listitem)?"/>

    <xsl:choose>
      <xsl:when test="empty($listitem)">
        <xsl:sequence select="1"/>
      </xsl:when>
      <xsl:when test="exists($listitem/db:para)">
        <xsl:sequence select="count($listitem/preceding-sibling::db:listitem) + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="local:listitem-index(($listitem/preceding-sibling::db:listitem)[last()])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xdoc:MARKDOWN//(@listtype | @listlevel)">
    <!-- Remove, no longer needed -->
  </xsl:template>
  
</xsl:stylesheet>
