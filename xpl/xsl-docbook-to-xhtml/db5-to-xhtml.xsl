<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*	
    Turns the db5 (xtpxlib-xdoc dialect) into an XHTML div element
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <xsl:mode on-no-match="fail"/>
  <xsl:mode name="mode-inline" on-no-match="fail"/>

  <xsl:variable name="id-index-name" as="xs:string" select="'id-index'" static="true"/>
  <xsl:key _name="{$id-index-name}" match="db:*" use="@xml:id"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="create-header" as="xs:string" required="false" select="string(true())"/>

  <xsl:param name="base-href" as="xs:string?" required="false" select="()"/>

  <xsl:variable name="do-create-header" as="xs:boolean" select="xtlc:str2bln($create-header, true())"/>

  <!-- ================================================================== -->
  <!-- GLOBAL VARIABLES: -->

  <xsl:variable name="original-document" as="document-node()" select="/"/>

  <xsl:variable name="is-book" as="xs:boolean" select="exists(/*/self::db:book)"/>

  <xsl:variable name="phase-description-main" as="xs:string" select="'main'"/>
  <xsl:variable name="phase-description-inline" as="xs:string" select="'inline'"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">
    <xsl:apply-templates>
      <xsl:with-param name="phase-description" as="xs:string" select="$phase-description-main" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/db:book | /db:article">
    <div class="{local-name(.)}">
      <xsl:apply-templates select="db:*"/>
    </div>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- HEADER CREATION: -->

  <xsl:template match="db:info">
    <xsl:if test="$create-header">
      <div class="header">
        <xsl:call-template name="add-header-info">
          <xsl:with-param name="source-element" select="db:title"/>
          <xsl:with-param name="element-name" select="'h1'"/>
        </xsl:call-template>
        <xsl:call-template name="add-header-info">
          <xsl:with-param name="source-element" select="db:subtitle"/>
          <xsl:with-param name="element-name" select="'h2'"/>
        </xsl:call-template>
        <xsl:call-template name="add-header-info">
          <xsl:with-param name="source-element" select="db:pubdate"/>
          <xsl:with-param name="element-name" select="'p'"/>
        </xsl:call-template>
        <xsl:call-template name="add-header-info">
          <xsl:with-param name="source-element" select="db:author"/>
          <xsl:with-param name="element-name" select="'p'"/>
        </xsl:call-template>
        <xsl:call-template name="add-header-info">
          <xsl:with-param name="source-element" select="db:orgname"/>
          <xsl:with-param name="element-name" select="'p'"/>
        </xsl:call-template>
        <xsl:for-each select="db:mediaobject[@role eq 'center-page'][1]/db:imageobject[1]/db:imagedata[1]">
          <xsl:call-template name="handle-imagedata">
            <xsl:with-param name="imagedata" select="."/>
            <xsl:with-param name="class" select="'header-image'"/>
          </xsl:call-template>
        </xsl:for-each>

        <p class="generate-timestamp">Generated: {format-dateTime(current-dateTime(), $xtlc:default-dt-format)}</p>
        <hr/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-header-info">
    <xsl:param name="source-element" as="element()?" required="yes"/>
    <xsl:param name="element-name" as="xs:string" required="yes"/>

    <xsl:variable name="text" as="xs:string?" select="string-join($source-element//text()[normalize-space(.) ne ''], '; ')"/>
    <xsl:if test="normalize-space($text) ne ''">
      <xsl:element name="{$element-name}">
        <xsl:attribute name="class" select="local-name($source-element)"/>
        <xsl:sequence select="$text"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- STRUCTURAL ELEMENTS: -->

  <xsl:template match="db:chapter | db:appendix | db:preface">
    <xsl:if test="not($is-book)">
      <xsl:call-template name="insert-error">
        <xsl:with-param name="msg-parts" select="('Non-books cannot contain: ', .)"/>
      </xsl:call-template>
    </xsl:if>
    <h1 class="{local-name(.)}">
      <xsl:call-template name="handle-inline-contents">
        <xsl:with-param name="contents" select="db:title/node()"/>
      </xsl:call-template>
    </h1>
    <xsl:apply-templates select="db:* except db:title"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:sect1 | db:sect2 | db:sect3">
    <xsl:variable name="level" as="xs:integer" select="xs:integer(substring-after(local-name(.), 'sect')) + (if ($is-book) then 1 else 0)"/>
    <xsl:element name="h{$level}">
      <xsl:attribute name="class" select="local-name(.)"/>
      <xsl:call-template name="handle-inline-contents">
        <xsl:with-param name="contents" select="db:title/node()"/>
      </xsl:call-template>
    </xsl:element>
    <xsl:apply-templates select="db:* except db:title"/>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- BLOCK CONTENTS: -->

  <xsl:template match="db:para | db:bridgehead">

    <xsl:variable name="roles" as="xs:string*" select="xtlc:str2seq(@role)"/>
    <xsl:variable name="is-halfbreak" as="xs:boolean" select="$roles = ('halfbreak')"/>
    <xsl:variable name="is-break" as="xs:boolean" select="$roles = ('break')"/>

    <xsl:if test="$roles = ('break-before')">
      <p class="break">&#160;</p>
    </xsl:if>
    <p class="{local-name(.)}">
      <xsl:call-template name="copy-id"/>
      <xsl:choose>
        <xsl:when test="$is-break or $is-halfbreak">
          <!-- Ignore any contents, just emit a hard-space: -->
          <xsl:text>&#160;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="handle-inline-contents">
            <xsl:with-param name="contents" select="node()"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </p>
    <xsl:if test="$roles = ('break-after')">
      <p class="break">&#160;</p>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:remark">
    <!-- Don't output for XHTML -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:itemizedlist | db:orderedlist | db:simplelist">
    <xsl:variable name="in-ordered-list" as="xs:boolean" select="exists(self::db:orderedlist)"/>
    <xsl:element name="{if ($in-ordered-list) then 'ol' else 'ul'}">
      <xsl:attribute name="class" select="local-name(.)"/>
      <xsl:call-template name="copy-id"/>
      <xsl:for-each select="db:listitem | db:member">
        <li>
          <xsl:call-template name="copy-id"/>
          <xsl:apply-templates select="db:*"/>
        </li>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!--<xsl:template match="db:figure | db:informalfigure">

    <block text-align="center" space-before="{local:dimpt(2 * $standard-paragraph-distance-pt)}"
      space-after="{local:dimpt(3 * $standard-paragraph-distance-pt)}" keep-with-previous="always">
      <xsl:call-template name="copy-id"/>
      <xsl:call-template name="handle-imagedata">
        <xsl:with-param name="imagedata" select="db:mediaobject/db:imageobject/db:imagedata"/>
      </xsl:call-template>
    </block>
    <xsl:if test="exists(self::db:figure)">
      <xsl:call-template name="add-object-title">
        <xsl:with-param name="object-name" select="'Figure'"/>
        <xsl:with-param name="align-left" select="false()"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>-->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!--<xsl:template match="db:programlisting">
    <xsl:param name="in-example" as="xs:boolean" required="no" select="false()" tunnel="true"/>

    <!-\- Remove trailing and leading whitespace and CR characters: -\->
    <xsl:variable name="contents-prepared" as="xs:string" select="string(.) => replace('^\s+', '') => replace('\s+$', '') => replace('&#x0d;', '')"/>
    <!-\- Break the contents down in lines: -\->
    <xsl:variable name="lines" as="xs:string*" select="tokenize($contents-prepared, '&#x0a;')"/>

    <xsl:variable name="space-before-after" as="xs:double" select="$standard-font-size div 2.0"/>
    <block keep-together.within-column="always" space-before="{local:dimpt($space-before-after)}" space-after="{local:dimpt($space-before-after)}">
      <xsl:if test="not($in-example)">
        <xsl:attribute name="margin-left" select="local:dimcm($standard-small-indent)"/>
        <xsl:attribute name="margin-right" select="local:dimcm($standard-small-indent)"/>
      </xsl:if>
      <xsl:call-template name="copy-id"/>
      <xsl:for-each select="$lines">
        <block xsl:use-attribute-sets="attributes-codeblock-font-settings">
          <!-\- Replace spaces with hard spaces so we keep the indent: -\->
          <xsl:choose>
            <xsl:when test=". eq ''">
              <xsl:text>&#160;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="translate(., ' ', '&#160;')"/>
            </xsl:otherwise>
          </xsl:choose>
        </block>
      </xsl:for-each>
    </block>
  </xsl:template>-->

 

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!--<xsl:template match="db:variablelist">

    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      <xsl:with-param name="keep-with-next" select="true()"/>
    </xsl:call-template>
    <xsl:for-each select="db:varlistentry">
      <xsl:for-each select="db:term">
        <block keep-with-next="always">
          <xsl:call-template name="handle-inline-text">
            <xsl:with-param name="contents" as="node()*" select="node()"/>
            <xsl:with-param name="bold" select="true()"/>
          </xsl:call-template>
        </block>
      </xsl:for-each>
      <block-container margin-left="{local:dimcm($standard-itemized-list-indent)}">
        <xsl:apply-templates select="db:listitem/db:*" mode="#current"/>
      </block-container>
      <xsl:call-template name="empty-line">
        <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>-->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!--<xsl:template match="db:note | db:warning">

    <xsl:variable name="roles" as="xs:string*" select="xtlc:str2seq(@role)"/>
    <xsl:variable name="is-note" as="xs:boolean" select="exists(self::db:note)"/>
    <xsl:variable name="is-special" as="xs:boolean" select="'special' = $roles"/>
    <xsl:variable name="title-color" as="xs:string" select="if ($is-note) then 'navy' else 'purple'"/>

    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      <xsl:with-param name="keep-with-next" select="true()"/>
    </xsl:call-template>
    <block margin-left="{local:dimcm($standard-itemized-list-indent)}" margin-right="{local:dimcm($standard-itemized-list-indent)}"
      padding="{local:dimcm($standard-small-indent)}" border="thin solid {$title-color}">
      <xsl:if test="$is-special">
        <xsl:attribute name="background-color" select="'#C0C0C0'"/>
      </xsl:if>
      <xsl:if test="not($is-special)">
        <block font-weight="bold" keep-with-next="always" color="{$title-color}">
          <xsl:choose>
            <xsl:when test="exists(db:title)">
              <xsl:call-template name="handle-inline-text">
                <xsl:with-param name="contents" select="db:title/node()"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="if ($is-note) then 'NOTE:' else 'WARNING:'"/>
            </xsl:otherwise>
          </xsl:choose>
        </block>
      </xsl:if>

      <xsl:apply-templates select="* except db:title" mode="#current"/>
    </block>
    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
    </xsl:call-template>
  </xsl:template>-->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!--<xsl:template match="db:sidebar">

    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      <xsl:with-param name="keep-with-next" select="true()"/>
    </xsl:call-template>
    <block border="solid 0.2mm black" margin-left="{local:dimcm($standard-itemized-list-indent)}"
      margin-right="{local:dimcm($standard-itemized-list-indent)}" padding="{local:dimcm($standard-small-indent)}">
      <block font-weight="bold" keep-with-next="always" margin-top="{local:dimpt($standard-paragraph-distance-pt)}" text-align="left"
        font-size="{local:dimpt($standard-font-size + 1)}">
        <xsl:call-template name="handle-inline-text">
          <xsl:with-param name="contents" select="db:title/node()"/>
          <xsl:with-param name="bold" select="true()"/>
        </xsl:call-template>
      </block>
      <xsl:apply-templates select="db:* except db:title" mode="#current"/>
    </block>
    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
    </xsl:call-template>
  </xsl:template>-->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!--<xsl:template match="db:example">

    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      <xsl:with-param name="keep-with-next" select="true()"/>
    </xsl:call-template>
    <block margin-left="{local:dimcm($standard-small-indent)}" margin-right="{local:dimcm($standard-small-indent)}">
      <xsl:apply-templates select="db:* except db:title" mode="#current">
        <xsl:with-param name="in-example" as="xs:boolean" select="true()" tunnel="true"/>
      </xsl:apply-templates>
      <xsl:call-template name="add-object-title">
        <xsl:with-param name="object-name" select="'Example'"/>
      </xsl:call-template>
    </block>
    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
    </xsl:call-template>
  </xsl:template>-->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!--<xsl:template name="add-object-title">
    <xsl:param name="object" as="element()" required="no" select="."/>
    <xsl:param name="object-name" as="xs:string?" required="no" select="()"/>
    <xsl:param name="align-left" as="xs:boolean" required="no" select="true()"/>

    <xsl:if test="(normalize-space($object/db:title) ne '') or exists($object/@number)">
      <block text-align="{if ($align-left) then 'left' else 'center'}" font-style="italic" font-size="{local:dimpt($special-titles-font-size)}"
        space-after="{local:dimpt($standard-font-size)}" keep-with-previous="always">
        <xsl:if test="exists($object-name) and exists($object/@number)">
          <xsl:value-of select="$object-name"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$object/@number"/>
          <xsl:if test="normalize-space(db:title) ne ''">
            <xsl:text>&#160;-&#160;</xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:call-template name="handle-inline-contents">
          <xsl:with-param name="contents" select="db:title/node()"/>
          <xsl:with-param name="small-font-size" select="true()"/>
        </xsl:call-template>
      </block>
    </xsl:if>
  </xsl:template>-->

  <!-- ================================================================== -->
  <!-- SPECIAL BLOCK: TABLES: -->

  <!--<xsl:template match="db:table | db:informaltable">

    <xsl:variable name="in-informal-table" as="xs:boolean" select="exists(self::db:informaltable)"/>

    <table space-before="{local:dimpt(2 * $standard-paragraph-distance-pt)}" space-after="{local:dimpt(3 * $standard-paragraph-distance-pt)}"
      font-size="{local:dimpt($standard-font-size - 1)}">
      <xsl:call-template name="copy-id"/>
      <xsl:if test="local:element-is-in-table(.)">
        <!-\- For a table-in-a-table, take a little more space at the right. -\->
        <xsl:attribute name="margin-right" select="local:dimpt($standard-font-size div 2.0)"/>
      </xsl:if>
      <xsl:apply-templates mode="mode-table" select="db:* except db:title">
        <xsl:with-param name="phase-description" as="xs:string" select="'table'" tunnel="true"/>
        <xsl:with-param name="in-informal-table" as="xs:boolean" select="$in-informal-table" tunnel="true"/>
        <xsl:with-param name="in-table" as="xs:boolean" select="true()" tunnel="true"/>
      </xsl:apply-templates>
    </table>

    <xsl:choose>
      <xsl:when test="$in-informal-table">
        <!-\- Not sure about this... -\->
        <!-\-<xsl:call-template name="empty-line">
          <xsl:with-param name="size-pt" select="$table-spacing-pt"/>
        </xsl:call-template>-\->
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="add-object-title">
          <xsl:with-param name="object-name" select="'Table'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>-->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:tgroup" mode="mode-table">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:colspec" mode="mode-table">
    <table-column>
      <xsl:if test="exists(@colwidth)">
        <xsl:attribute name="column-width" select="@colwidth"/>
      </xsl:if>
    </table-column>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:thead" mode="mode-table">
    <xsl:param name="in-informal-table" as="xs:boolean" required="true" tunnel="true"/>

    <table-header>
      <xsl:if test="not($in-informal-table)">
        <xsl:attribute name="color" select="'white'"/>
        <xsl:attribute name="background-color" select="'black'"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </table-header>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:tbody" mode="mode-table">
    <table-body>
      <xsl:apply-templates mode="#current"/>
    </table-body>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:row" mode="mode-table">
    <table-row keep-together.within-column="always">
      <xsl:call-template name="copy-id"/>

      <xsl:choose>
        <xsl:when test="position() le 2">
          <xsl:attribute name="keep-with-next" select="'always'"/>
        </xsl:when>
        <xsl:when test="position() eq last()">
          <xsl:attribute name="keep-with-previous" select="'always'"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>

      <xsl:call-template name="copy-id"/>
      <xsl:apply-templates mode="#current"/>
    </table-row>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!--<xsl:template match="db:entry" mode="mode-table">
    <xsl:param name="in-informal-table" as="xs:boolean" required="true" tunnel="true"/>

    <table-cell padding="{local:dimpt(1)}" margin-left="0">
      <xsl:if test="not($in-informal-table)">
        <xsl:attribute name="border" select="'solid 0.1mm black'"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="empty(db:para)">
          <!-\- No surrounding <para> or so it seems, create one: -\->
          <xsl:call-template name="handle-block-contents">
            <xsl:with-param name="contents" as="element()*">
              <db:para>
                <xsl:sequence select="node()"/>
              </db:para>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="handle-block-contents">
            <xsl:with-param name="contents" select="*"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </table-cell>
  </xsl:template>-->

  <!-- ================================================================== -->
  <!-- INLINE CONTENTS: -->

  <xsl:template name="handle-inline-contents">
    <xsl:param name="contents" as="node()*" required="no" select="node()"/>

    <xsl:apply-templates select="$contents" mode="mode-inline">
      <xsl:with-param name="phase-description" as="xs:string" select="$phase-description-inline" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:xref" mode="mode-inline">

    <xsl:variable name="id" as="xs:string" select="@linkend"/>
    <xsl:variable name="referenced-element" as="element()?" select="key($id-index-name, $id, $original-document)"/>
    <xsl:variable name="roles" as="xs:string*" select="xtlc:str2seq(@role)"/>
    <xsl:variable name="do-capitalize" as="xs:boolean" select="'capitalize' = $roles"/>
    <xsl:variable name="text-only" as="xs:boolean" select="'text' = $roles"/>

    <xsl:choose>
      <xsl:when test="exists($referenced-element)">
        <basic-link internal-destination="{$id}">
          <xsl:choose>
            <xsl:when test="'page-number-only' = $roles">
              <page-number-citation ref-id="{$referenced-element/@xml:id}"/>
            </xsl:when>
            <xsl:when test="'simple' = $roles">
              <xsl:value-of select="local:xref-capitalize('page&#160;', $do-capitalize)"/>
              <page-number-citation ref-id="{$referenced-element/@xml:id}"/>
            </xsl:when>
            <xsl:when test="exists($referenced-element/@xreflabel)">
              <xsl:choose>
                <xsl:when test="$text-only">
                  <xsl:value-of select="$referenced-element/@xreflabel"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>&quot;</xsl:text>
                  <xsl:value-of select="$referenced-element/@xreflabel"/>
                  <xsl:text>&quot; on page&#160;</xsl:text>
                  <page-number-citation ref-id="{$referenced-element/@xml:id}"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$referenced-element/self::db:chapter">
              <xsl:value-of select="local:xref-capitalize('chapter&#160;', $do-capitalize)"/>
              <xsl:value-of select="$referenced-element/@number"/>
            </xsl:when>
            <xsl:when test="$referenced-element/self::db:appendix">
              <xsl:value-of select="local:xref-capitalize('appendix&#160;', $do-capitalize)"/>
              <xsl:value-of select="$referenced-element/@number"/>
            </xsl:when>
            <xsl:when test="matches(local-name($referenced-element), '^sect[0-9]$')">
              <xsl:choose>
                <xsl:when test="$text-only">
                  <xsl:value-of select="normalize-space($referenced-element/db:title)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>"</xsl:text>
                  <xsl:value-of select="normalize-space($referenced-element/db:title)"/>
                  <xsl:text>" on page&#160;</xsl:text>
                  <page-number-citation ref-id="{$referenced-element/@xml:id}"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text>"</xsl:text>
              <xsl:value-of select="normalize-space($referenced-element/db:title)"/>
              <xsl:text>" on page&#160;</xsl:text>
              <page-number-citation ref-id="{$referenced-element/@xml:id}"/>
            </xsl:when>
            <xsl:when
              test="$referenced-element/self::db:figure[exists(@number)] or $referenced-element/self::db:table[exists(@number)] or
                $referenced-element/self::db:example[exists(@number)]">
              <xsl:value-of select="local:xref-capitalize(local-name($referenced-element), $do-capitalize)"/>
              <xsl:text>&#160;</xsl:text>
              <xsl:value-of select="$referenced-element/@number"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="local:xref-capitalize('page&#160;', $do-capitalize)"/>
              <page-number-citation ref-id="{$referenced-element/@xml:id}"/>
            </xsl:otherwise>
          </xsl:choose>
        </basic-link>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="insert-error">
          <xsl:with-param name="msg-parts" select="('Referenced linkend id ', xtlc:q(@linkend), ' not found')"/>
          <xsl:with-param name="block" select="false()"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:xref-capitalize" as="xs:string">
    <!-- Helper function for creating xref texts with capitalization or not. -->
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="capitalize" as="xs:boolean"/>
    <xsl:sequence select="if ($capitalize) then xtlc:capitalize($text) else $text"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:emphasis" mode="mode-inline">

    <xsl:variable name="role" as="xs:string*" select="normalize-space(@role)"/>
    <xsl:variable name="bold" as="xs:boolean" select="$role eq 'bold'"/>
    <xsl:variable name="underline" as="xs:boolean" select="$role eq 'underline'"/>

    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="bold" select="$bold"/>
      <xsl:with-param name="underline" select="$underline"/>
      <xsl:with-param name="italic" select="not($bold) and not($underline)"/>
    </xsl:call-template>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:code | db:literal" mode="mode-inline">
    <xsl:param name="in-table" as="xs:boolean" required="no" select="false()" tunnel="true"/>

    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="fixed-width" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:link" mode="mode-inline">
    <a href="{@xlink:href}">
      <xsl:call-template name="handle-inline-text">
        <xsl:with-param name="text" select="if (normalize-space(.) eq '') then @xlink:href else ()"/>
      </xsl:call-template>
    </a>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:inlinemediaobject" mode="mode-inline">
    <xsl:call-template name="handle-imagedata">
      <xsl:with-param name="imagedata" select="db:imageobject/db:imagedata"/>
      <xsl:with-param name="block" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:citation" mode="mode-inline">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="#current"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:command" mode="mode-inline">
    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="italic" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:email" mode="mode-inline">
    <a href="mailto:{normalize-space(.)}">
      <xsl:call-template name="handle-inline-text">
        <xsl:with-param name="italic" select="true()"/>
      </xsl:call-template>
    </a>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:filename" mode="mode-inline">
    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="italic" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:replaceable" mode="mode-inline">
    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="italic" select="true()"/>
      <xsl:with-param name="fixed-width" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:userinput" mode="mode-inline">
    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="bold" select="true()"/>
      <xsl:with-param name="fixed-width" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:keycap" mode="mode-inline">
    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="bold" select="true()"/>
      <xsl:with-param name="fixed-width" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:superscript" mode="mode-inline">
    <sup>
      <xsl:apply-templates mode="#current"/>
    </sup>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:subscript" mode="mode-inline">
    <sub>
      <xsl:apply-templates mode="#current"/>
    </sub>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:tag" mode="mode-inline">
    <xsl:param name="in-table" as="xs:boolean" required="no" select="false()" tunnel="true"/>

    <xsl:variable name="class" as="xs:string" select="(@class, 'element')[1]"/>
    <xsl:variable name="contents" as="xs:string">
      <xsl:choose>
        <xsl:when test="$class eq 'attribute'">
          <xsl:sequence select="'@' || string(.)"/>
        </xsl:when>
        <xsl:when test="$class eq 'attvalue'">
          <xsl:sequence select="'&quot;' || string(.) || '&quot;'"/>
        </xsl:when>
        <xsl:when test="$class eq 'emptytag'">
          <xsl:sequence select="'&lt;' || string(.) || '/&gt;'"/>
        </xsl:when>

        <xsl:when test="$class eq 'endtag'">
          <xsl:sequence select="'&lt;/' || string(.) || '&gt;'"/>
        </xsl:when>
        <xsl:when test="$class eq 'pi'">
          <xsl:sequence select="'&lt;?' || string(.) || '?&gt;'"/>
        </xsl:when>
        <xsl:when test="$class eq 'comment'">
          <xsl:sequence select="'&lt;!--' || string(.) || '--&gt;'"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Default, suppose element: -->
          <xsl:sequence select="'&lt;' || string(.) || '&gt;'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="contents" as="node()*">
        <xsl:value-of select="$contents"/>
      </xsl:with-param>
      <xsl:with-param name="fixed-width" select="true()"/>
    </xsl:call-template>
  </xsl:template>


  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text()" mode="mode-inline">
    <!-- Mark anything like [TBD...] -->
    <xsl:analyze-string select="string(.)" regex="\[TBD.*?\]" flags="is">
      <xsl:matching-substring>
        <span class="tbd-marker">
          <xsl:copy/>
        </span>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:copy/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="handle-inline-text" as="element()">
    <xsl:param name="class" as="xs:string" required="false" select="local-name(.)"/>
    <xsl:param name="contents" as="node()*" required="no" select="node()"/>
    <xsl:param name="text" as="xs:string?" required="no" select="()"/>
    <!-- When $text is specified, $contents is ignored. -->
    <xsl:param name="bold" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="italic" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="underline" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="fixed-width" as="xs:boolean" required="no" select="false()"/>

    <xsl:variable name="inline-attributes" as="attribute()*">
      <xsl:attribute name="class" select="$class"/>
      <xsl:if test="$bold">
        <xsl:attribute name="font-weight" select="'bold'"/>
      </xsl:if>
      <xsl:if test="$italic">
        <xsl:attribute name="font-style" select="'italic'"/>
      </xsl:if>
      <xsl:if test="$underline">
        <xsl:attribute name="text-decoration" select="'underline'"/>
      </xsl:if>

    </xsl:variable>
    <xsl:variable name="inline-contents" as="item()*">
      <xsl:choose>
        <xsl:when test="exists($text)">
          <xsl:value-of select="$text"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$contents" mode="mode-inline"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="{if ($fixed-width) then 'code' else 'span'}">
      <xsl:sequence select="$inline-attributes"/>
      <xsl:sequence select="$inline-contents"/>
    </xsl:element>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template match="*" mode="#all" priority="-1000">
    <xsl:call-template name="insert-error">
      <xsl:with-param name="msg-parts" select="('Unrecognized element: ', .)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="insert-error">
    <xsl:param name="msg-parts" as="item()+" required="yes"/>
    <xsl:param name="phase-description" as="xs:string?" required="false" select="()" tunnel="true"/>
    <xsl:param name="block" as="xs:boolean" required="false" select="$phase-description ne $phase-description-inline"/>

    <xsl:variable name="phase-phrase" as="xs:string" select="if (empty($phase-description)) then '' else concat(' (phase: ', $phase-description, ')')"/>
    <xsl:element name="{if ($block) then 'p' else 'span'}">
      <xsl:attribute name="class" select="'error'"/>
      <xsl:sequence select="'[*** ' || xtlc:items2str(($msg-parts, $phase-phrase)) || ']'"/>
    </xsl:element>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="handle-imagedata">
    <xsl:param name="imagedata" as="element(db:imagedata)*" required="yes"/>
    <xsl:param name="block" as="xs:boolean" required="no" select="true()"/>
    <xsl:param name="class" as="xs:string?" required="false" select="()"/>

    <xsl:choose>
      <xsl:when test="exists($imagedata)">
        <xsl:for-each select="$imagedata">
          <xsl:variable name="current-imagedata" as="element(db:imagedata)" select="."/>
          <xsl:variable name="full-uri" as="xs:string" select="local:get-full-uri($current-imagedata/@fileref)"/>
          <!--<xsl:variable name="width" as="xs:string?" select="$current-imagedata/@width"/>
          <xsl:variable name="height" as="xs:string?" select="$current-imagedata/@height"/>-->
          <img src="{$full-uri}">
            <xsl:if test="exists($class)">
              <xsl:attribute name="class" select="$class"/>
            </xsl:if>
            <!-- TBD: Anything we need to do with width and height? -->
            <!--<xsl:if test="exists($width)">
              <xsl:attribute name="width" select="$width"/>
            </xsl:if>
            <xsl:if test="exists($height)">
              <xsl:attribute name="height" select="$height"/>
            </xsl:if>-->
          </img>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="insert-error">
          <xsl:with-param name="msg-parts" select="'Invalid image reference (no imagedata)'"/>
          <xsl:with-param name="block" select="$block"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-full-uri" as="xs:string">
    <!-- Turns a href into a full path  by adding the supplied $base-href. -->
    <xsl:param name="href" as="xs:string"/>
    <xsl:sequence select="xtlc:href-canonical(xtlc:href-concat(($base-href, $href)))"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template name="copy-id">
    <xsl:param name="elm" as="element()" required="no" select="."/>
    <xsl:if test="exists($elm/@xml:id)">
      <xsl:attribute name="id" select="$elm/@xml:id"/>
    </xsl:if>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="comment() | processing-instruction()">
    <!-- Ignore -->
  </xsl:template>




</xsl:stylesheet>
