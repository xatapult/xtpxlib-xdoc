<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*	
    Handle columns like <colspec role="code-width-cm:1.2-4"/> and computes their actual colwidth setting.
    The actual computed column width will be based on contents in <code role="code-width-limited"> elements in the column's contents.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/xdoclib.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="main-font-size" as="xs:string" required="true"/>
  <xsl:variable name="main-font-size-dbl" as="xs:double" select="xs:double($main-font-size)"/>

  <!-- ================================================================== -->
  <!-- GLOBALS: -->

  <xsl:variable name="code-width-cm-role" as="xs:string" select="'code-width-cm:'"/>
  <xsl:variable name="code-width-limited-role" as="xs:string" select="'code-width-limited'"/>

  <!-- An educated guess about the number of fixed width characters per cm.  -->
  <xsl:variable name="fixed-width-characters-per-cm-dbl" as="xs:double" select="xdoc:fixed-width-characters-per-cm-dbl($main-font-size-dbl)"/>

  <!-- ================================================================== -->

  <xsl:template match="db:colspec[some $role in xtlc:str2seq(@role) satisfies starts-with($role, $code-width-cm-role)]">
    <xsl:copy>
      <xsl:copy-of select="@* except @colwidth"/>

      <!-- The role has the format: code-width-cm:min-max, where min and max are doubles (expressed in cm). Get them: -->
      <xsl:variable name="code-with-cm-role-full" as="xs:string" select="(xtlc:str2seq(@role)[starts-with(., $code-width-cm-role)])[1]"/>
      <xsl:variable name="min-max" as="xs:string*" select="tokenize(substring-after($code-with-cm-role-full, $code-width-cm-role), '-')"/>
      <xsl:variable name="min-width-cm" as="xs:double" select="local:str2dbl($min-max[1])"/>
      <xsl:variable name="max-width-cm" as="xs:double" select="local:str2dbl($min-max[2])"/>
      <xsl:if test="($min-width-cm lt 0) or ($max-width-cm le 0)">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Invalid code-with-cm role: ', xtlc:q($code-with-cm-role-full))"/>
        </xsl:call-template>
      </xsl:if>

      <!-- Compute the column number/index. This is probably not correct against the full DocBook spec, because there is also
        a @colnum. Let's just assume that all colspec elements are in the right order. -->
      <xsl:variable name="column-number" as="xs:integer" select="count(preceding-sibling::db:colspec) + 1"/>

      <!-- Get all the textual contents of the <code role="code-width-limited"> elements in the right columns.
        The implicit assumption here is that such a <code> element is always a single paragraph. -->
      <xsl:variable name="code-width-limited-contents" as="xs:string*">
        <xsl:for-each select="../(db:thead | db:tbody)/db:row/db:entry[$column-number]">
          <xsl:for-each select=".//db:code[$code-width-limited-role = xtlc:str2seq(@role)]">
            <xsl:sequence select="string(.)"/>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:variable>

      <!-- And compute a column width from this: -->
      <xsl:attribute name="colwidth"
        select="local:compute-fixed-width-column-width-cm($code-width-limited-contents, $min-width-cm, $max-width-cm) || 'cm'"/>

      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:compute-fixed-width-column-width-cm" as="xs:double">
    <xsl:param name="texts" as="xs:string*"/>
    <xsl:param name="min-width-cm" as="xs:double"/>
    <xsl:param name="max-width-cm" as="xs:double"/>

    <xsl:variable name="max-nr-of-characters" as="xs:integer" select="(max(for $t in $texts return string-length($t)), 0)[1]"/>
    <xsl:variable name="width-based-on-nr-of-characters-cm" as="xs:double" select="$max-nr-of-characters div $fixed-width-characters-per-cm-dbl"/>
    <!-- Find the right width and add just a  tiny bit to make sure everything goes ok (otherwise sometimes words still go to the next line) -->
    <xsl:variable name="width-cm" as="xs:double" select="max(($min-width-cm, $width-based-on-nr-of-characters-cm)) + 0.3"/>
    <xsl:sequence select="if ($width-cm gt $max-width-cm) then $max-width-cm else $width-cm"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:str2dbl" as="xs:double">
    <!-- Tries to convert $in to a double. If not successful returns -1 (negative values are always wrong in this context). -->
    <xsl:param name="in" as="xs:string?"/>

    <xsl:choose>
      <xsl:when test="exists($in) and ($in castable as xs:double)">
        <xsl:sequence select="xs:double($in)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="-1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
