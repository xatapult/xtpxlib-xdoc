<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.lvc_d53_h3b"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Processes any alt settings (like altcolspecs)
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-change-colspec" on-no-match="shallow-copy"/>
  <xsl:mode name="mode-change-imagedata" on-no-match="shallow-copy"/>

  <xsl:variable name="altcolspecs-keyname" as="xs:string" select="'altcolspecs'"/>
  <xsl:key name="altcolspecs" match="xdoc:altcolspecs" use="@idref"/>

  <xsl:variable name="altimagedata-keyname" as="xs:string" select="'altimagedata'"/>
  <xsl:key name="altimagedata" match="xdoc:altimagedata" use="@idref"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS: -->

  <xsl:param name="alttarget" as="xs:string" required="yes">
    <!-- The alttarget can be a whitespace separated list of target names. 
      The software tries to find the first one first. if not found, it tries the second one, etc. 
    -->
  </xsl:param>

  <xsl:variable name="alttarget-names" as="xs:string*" select="tokenize($alttarget, '\s+')[.]"/>

  <!-- ======================================================================= -->
  <!-- BYPASS ALL PROCESSING WHEN NO ALTTARGET IS SET: -->

  <xsl:template match="/*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="empty($alttarget-names)">
          <xsl:comment> == No alttarget set == </xsl:comment>
          <xsl:copy-of select="node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment> == Using alttarget(s) "{string-join($alttarget-names, ' ')}" == </xsl:comment>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- ALTERNATIVE COLSPECS FOR TABLES: -->

  <xsl:template match="db:table[@xml:id] | db:informaltable[@xml:id]">
    <xsl:variable name="id" as="xs:string" select="string(@xml:id)"/>
    <xsl:variable name="altcolspecs" as="element(xdoc:altcolspecs)*"
      select="key($altcolspecs-keyname, $id)[@target = $alttarget-names]"/>

    <xsl:choose>
      <xsl:when test="exists($altcolspecs)">
        <xsl:variable name="altcolspec" as="element(xdoc:altcolspecs)*"
          select="local:get-first-for-alttargets($altcolspecs)"/>
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:comment> == colspecs set for target "{$altcolspec/@target}" == </xsl:comment>
          <xsl:apply-templates mode="mode-change-colspec">
            <xsl:with-param name="alt-colspecs" as="element(xdoc:colspec)*"
              select="$altcolspec/xdoc:colspec" tunnel="true"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:colspec" mode="mode-change-colspec">
    <xsl:param name="alt-colspecs" as="element(xdoc:colspec)*" required="true" tunnel="true"/>

    <!-- Find the index of the current colspec element and find the same one in the alternative set: -->
    <xsl:variable name="colspec-index" as="xs:integer"
      select="count(preceding-sibling::db:colspec) + 1"/>
    <xsl:variable name="alt-colspec" as="element(xdoc:colspec)?"
      select="$alt-colspecs[$colspec-index]"/>
    <xsl:choose>
      <xsl:when test="exists($alt-colspec)">
        <db:colspec>
          <xsl:copy-of select="$alt-colspec/@*"/>
        </db:colspec>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:table | db:informaltable" mode="mode-change-colspec">
    <!-- When finding a nested table. switch back to the default mode: -->
    <xsl:apply-templates select="." mode="#unnamed"/>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- ALTERNATIVE IMAGE DATA PROCESSING -->

  <xsl:template match="db:figure[@xml:id]" mode="#all">
    <xsl:variable name="id" as="xs:string" select="string(@xml:id)"/>
    <xsl:variable name="altimagedatas" as="element(xdoc:altimagedata)*"
      select="key($altimagedata-keyname, $id)[@target = $alttarget-names]"/>

    <xsl:choose>
      <xsl:when test="exists($altimagedatas)">
        <xsl:variable name="altimagedata" as="element(xdoc:altimagedata)?"
          select="local:get-first-for-alttargets($altimagedatas)"/>
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:comment> == altimagedata set for target "{$altimagedata/@target}" == </xsl:comment>
          <xsl:apply-templates mode="mode-change-imagedata">
            <xsl:with-param name="alt-imagedata" as="element(xdoc:altimagedata)?"
              select="$altimagedata" tunnel="true"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:imagedata" mode="mode-change-imagedata">
    <xsl:param name="alt-imagedata" as="element(xdoc:altimagedata)?" required="true" tunnel="true"/>

    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="$alt-imagedata/@* except ($alt-imagedata/@idref, $alt-imagedata/@target)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- SUPPORT -->

  <xsl:function name="local:get-first-for-alttargets" as="element()?">
    <xsl:param name="elements" as="element()*">
      <!-- These elements must have a @target. This is held against the list of alttargets and 
        the first one selected -->
    </xsl:param>

    <xsl:iterate select="$alttarget-names">
      <xsl:variable name="alttarget-name" as="xs:string" select="."/>
      <xsl:variable name="applicable-element" as="element()?"
        select="$elements[exists(@target)][@target eq $alttarget-name][1]"/>
      <xsl:if test="exists($applicable-element)">
        <xsl:break select="$applicable-element"/>
      </xsl:if>
    </xsl:iterate>

  </xsl:function>

  <!-- ================================================================== -->

  <xsl:template match="db:annoying-warning-suppression-template"/>
  <xsl:template match="xdoc:annoying-warning-suppression-template"/>

</xsl:stylesheet>
