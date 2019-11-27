<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local-xdoc-to-moduledoc-website" xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*	
    TBD
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="component-name" as="xs:string" select="/*/@component-name"/>

  <xsl:variable name="add-footer" as="xs:boolean" select="false()"/>

  <!-- ================================================================== -->

  <xsl:template match="xhtml:div[@class = ('chapter', 'preface', 'appendix')]">
    <!-- Don't copy this div itself -->
    <div class="container">
      <xsl:apply-templates select="*"/>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:h1">
    <div class="page-header">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:span['bold' = xtlc:str2seq(@class)]">
    <b>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:div[@class eq 'toc']">
    <!-- Rework TOC to bootstrap style -->
    <nav class="navbar navbar-default navbar-fixed-top">
      <div class="container">
        <xsl:variable name="toc-level-0" as="element(xhtml:ul)?" select="xhtml:ul[@class eq 'toc-level-0']"/>

        <div class="navbar-header">
          <xsl:variable name="first-link" as="element(xhtml:a)" select="$toc-level-0/xhtml:li[1]/xhtml:a"/>
          <a class="navbar-brand" href="{$first-link/@href}">{ $component-name }</a>
        </div>

        <div id="navbar" class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <xsl:for-each select="$toc-level-0/xhtml:li[position() gt 1]">
              <li>
                <xsl:if test="position() eq 1">
                  <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <xsl:variable name="toc-level-1" as="element(xhtml:ul)?" select="xhtml:ul[@class eq 'toc-level-1']"/>

                <xsl:choose>
                  <xsl:when test="exists($toc-level-1)">
                    <xsl:attribute name="class" select="'dropdown'"/>
                    <xsl:variable name="entry-main-title" as="xs:string" select="string(xhtml:a)"/>
                    <xsl:variable name="entry-main-title-no-numbers" as="xs:string" select="replace($entry-main-title, '^[0-9.]+\s+', '')"/>
                    <xsl:variable name="entry-main-href" as="xs:string" select="xhtml:a/@href"/>
                    <a href="{$entry-main-href}" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true"
                      aria-expanded="false">
                      <xsl:value-of select="$entry-main-title-no-numbers"/>
                      <xsl:text> </xsl:text>
                      <span class="caret"/>
                    </a>
                    <xsl:for-each select="$toc-level-1">
                      <ul class="dropdown-menu">
                        <li>
                          <a href="{$entry-main-href}">
                            <xsl:value-of select="$entry-main-title"/>
                          </a>
                        </li>
                        <li role="separator" class="divider"/>
                        <xsl:for-each select="xhtml:li">
                          <li>
                            <xsl:copy-of select="xhtml:a"/>
                          </li>
                        </xsl:for-each>
                      </ul>
                    </xsl:for-each>

                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="xhtml:a"/>
                  </xsl:otherwise>
                </xsl:choose>



              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </nav>

    <!-- Footer: -->
    <xsl:if test="$add-footer">
      <footer class="footer">
        <div class="container">
          <p class="text-muted">
            <xsl:apply-templates select="xhtml:h1[@class eq 'toc-header']/node()"/>
          </p>
        </div>
      </footer>
    </xsl:if>

  </xsl:template>


  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template match="xtlcon:annoying-warning-suppression-template"/>

</xsl:stylesheet>
