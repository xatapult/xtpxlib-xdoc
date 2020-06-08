<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:local="#local-u67gh"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true"
  xmlns="http://docbook.org/ns/docbook">
  <!-- ================================================================== -->
  <!--~
    Creates a directory overview.
    
    Input to this stylesheet is an XProc style recursive directory listing, for instance:
    
    ```
    <c:directory xmlns:c="http://www.w3.org/ns/xproc-step"
             name="xslmod"
             xml:base="file:///C:/Data/Erik/work/xatapult/xtpxlib-common/xslmod/">
      <c:file name="compare.mod.xsl"
              href-abs="file:///C:/Data/Erik/work/xatapult/xtpxlib-common/xslmod/compare.mod.xsl"
              href-rel="compare.mod.xsl"/>
      …
   </c:directory>
   ```
    
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../xsl-code-docgen/code-docgen-shared.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="full-dir" as="xs:string" required="yes">
    <!-- Debug reporting only -->
  </xsl:param>
  <xsl:param name="filter" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="base-dir" as="xs:string" select="/*/@xml:base"/>

  <!-- ================================================================== -->

  <xsl:template match="/">

    <xdoc:GROUP>
      <xsl:variable name="module-file-entries" as="element(c:file)*" select="/*/c:file[($filter eq '') or matches(@name, $filter)]"/>
      <xsl:choose>
        <xsl:when test="exists($module-file-entries)">
          <table>
            <title>Module overview</title>
            <tgroup cols="2">
              <colspec role="code-width-cm:1.5-4"/>
              <colspec/>
              <thead>
                <row>
                  <entry>Module/Pipeline</entry>
                  <entry>Description</entry>
                </row>
              </thead>
              <xsl:where-populated>
                <tbody>
                  <xsl:for-each select="$module-file-entries">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="filename" as="xs:string" select="@name"/>
                    <xsl:variable name="href-file" as="xs:string" select="@href-abs"/>
                    <row>
                      <entry>
                        <para>
                          <code role="code-width-limited">
                            <link linkend="{$filename}">{ $filename }</link>
                          </code>
                        </para>
                      </entry>
                      <entry>
                        <xsl:variable name="doc" as="document-node()" select="doc($href-file)"/>
                        <xsl:apply-templates select="$doc/*"/>
                      </entry>
                    </row>
                  </xsl:for-each>
                </tbody>
              </xsl:where-populated>
            </tgroup>
          </table>
        </xsl:when>
        <xsl:otherwise>
          <para>
            <emphasis role="bold">*** No modules found for path="{$full-dir}" filter="{$filter}"</emphasis>
          </para>
        </xsl:otherwise>
      </xsl:choose>

    </xdoc:GROUP>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xsl:stylesheet | xsl:transform">
    <xsl:call-template name="get-element-documentation">
      <xsl:with-param name="header-only" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="p:declare-step | p:library">
    <xsl:call-template name="xpl-get-element-documentation">
      <xsl:with-param name="header-only" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xs:schema">
    <xsl:call-template name="xsd-get-element-documentation">
      <xsl:with-param name="header-only" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" priority="-1">
    <xsl:call-template name="get-element-documentation">
      <xsl:with-param name="header-only" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template match="c:warning-prevention-template"/>

</xsl:stylesheet>
