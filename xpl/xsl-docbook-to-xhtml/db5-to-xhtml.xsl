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

  <xsl:variable name="do-create-header" as="xs:boolean" select="xtlc:str2bln($create-header, true())"/>

  <!-- ================================================================== -->
  <!-- GLOBAL VARIABLES: -->

  <xsl:variable name="original-document" as="document-node()" select="/"/>

  <xsl:variable name="is-book" as="xs:boolean" select="exists(/*/self::db:book)"/>

  <xsl:variable name="phase-description-main" as="xs:string" select="'main'"/>
  <xsl:variable name="phase-description-inline" as="xs:string" select="'inline'"/>

  <xsl:variable name="all-linkend-references" as="xs:string*" select="distinct-values((//db:xref/@linkend/string(), //db:link/@linkend/string()))"/>

  <xsl:variable name="ignore-object-titles" as="xs:boolean" select="true()"/>

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
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
        <xsl:with-param name="force" select="true()"/>
      </xsl:call-template>
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
          <img src="{@fileref}" class="header-image">
            <xsl:copy-of select="@width, @height"/>
          </img>
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
    <div class="{local-name(.)}">
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
        <xsl:with-param name="force" select="true()"/>
      </xsl:call-template>
      <h1 class="{local-name(.)}">
        <xsl:if test="not(self::db:preface)">
          <span class="{local-name(.)}-number">
            <xsl:value-of select="@number"/>
            <xsl:text> </xsl:text>
          </span>
        </xsl:if>
        <xsl:call-template name="handle-inline-contents">
          <xsl:with-param name="contents" select="db:title/node()"/>
        </xsl:call-template>
      </h1>
      <xsl:apply-templates select="db:* except db:title"/>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:sect1 | db:sect2 | db:sect3">
    <xsl:variable name="level" as="xs:integer" select="xs:integer(substring-after(local-name(.), 'sect')) + (if ($is-book) then 1 else 0)"/>
    <div class="{local-name(.)}">
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
        <xsl:with-param name="force" select="true()"/>
      </xsl:call-template>
      <xsl:element name="h{$level}">
        <xsl:attribute name="class" select="local-name(.)"/>
        <span class="{local-name(.)}-number">
          <xsl:value-of select="@number"/>
        </span>
        <xsl:text> </xsl:text>
        <xsl:call-template name="handle-inline-contents">
          <xsl:with-param name="contents" select="db:title/node()"/>
        </xsl:call-template>
      </xsl:element>
      <xsl:apply-templates select="db:* except db:title"/>
    </div>
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
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
      </xsl:call-template>
      <xsl:if test="$is-halfbreak">
        <xsl:attribute name="style" select="'font-size: 50%;'"/>
      </xsl:if>
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
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
      </xsl:call-template>
      <xsl:for-each select="db:listitem | db:member">
        <li>
          <xsl:call-template name="copy-id">
            <xsl:with-param name="create-anchor" select="true()"/>
          </xsl:call-template>
          <xsl:choose>
            <xsl:when test="self::db:member">
              <xsl:call-template name="handle-inline-contents"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="db:*"/>
            </xsl:otherwise>
          </xsl:choose>
        </li>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:figure | db:informalfigure">
    <xsl:variable name="imagedata" as="element(db:imagedata)" select="(.//db:imagedata)[1]"/>

    <p class="{local-name(.)}">
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
      </xsl:call-template>
      <img src="{$imagedata/@fileref}" class="{local-name(.)}">
        <xsl:copy-of select="$imagedata/@width, $imagedata/@height"/>
      </img>
      <xsl:if test="exists(self::db:figure)">
        <br/>
        <xsl:call-template name="add-object-title">
          <xsl:with-param name="object-name" select="'Figure'"/>
        </xsl:call-template>
      </xsl:if>
    </p>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:programlisting">
    <xsl:param name="in-example" as="xs:boolean" required="no" select="false()" tunnel="true"/>

    <!-- Remove trailing and leading whitespace and CR characters before output: -->
    <xsl:variable name="contents-prepared" as="xs:string" select="string(.) => replace('^\s+', '') => replace('\s+$', '') => replace('&#x0d;', '')"/>
    <div class="{local-name(.)}">
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
      </xsl:call-template>
      <pre class="{local-name(.)}"><xsl:value-of select="$contents-prepared"/></pre>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:variablelist">

    <dl class="{local-name(.)}">
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
      </xsl:call-template>
      <xsl:for-each select="db:varlistentry">
        <dt>
          <xsl:call-template name="handle-inline-contents">
            <xsl:with-param name="contents" select="db:term/node()"/>
          </xsl:call-template>
        </dt>
        <dd>
          <xsl:apply-templates select="db:listitem/db:*"/>
        </dd>
      </xsl:for-each>
    </dl>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:note | db:warning | db:sidebar">

    <div class="{local-name(.)}">
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
      </xsl:call-template>
      <p class="{local-name(.)}-title">
        <xsl:choose>
          <xsl:when test="exists(db:title)">
            <xsl:call-template name="handle-inline-text">
              <xsl:with-param name="contents" select="db:title/node()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <!-- For now generate nothing -->
            <!--<xsl:value-of select="upper-case(local-name(.)) || ':'"/>-->
          </xsl:otherwise>
        </xsl:choose>
      </p>
      <xsl:apply-templates select="* except db:title" mode="#current"/>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:example">

    <div class="{local-name(.)}">
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
      </xsl:call-template>
      <xsl:apply-templates select="* except db:title" mode="#current"/>
      <xsl:call-template name="add-object-title">
        <xsl:with-param name="object-name" select="'Example'"/>
      </xsl:call-template>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-object-title">
    <xsl:param name="object" as="element()" required="no" select="."/>
    <xsl:param name="object-name" as="xs:string?" required="no" select="()"/>

    <xsl:if test="not($ignore-object-titles)">
      <xsl:if test="(normalize-space($object/db:title) ne '') or exists($object/@number)">
        <p class="{local-name($object)}-title">
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
          </xsl:call-template>
        </p>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SPECIAL BLOCK: TABLES: -->

  <xsl:template match="db:table | db:informaltable">

    <div class="{local-name(.)}">
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
      </xsl:call-template>
      <table class="{local-name(.)}">
        <xsl:apply-templates mode="mode-table" select="db:* except db:title"/>
      </table>
      <xsl:call-template name="add-object-title">
        <xsl:with-param name="object-name" select="'Table'"/>
      </xsl:call-template>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:tgroup" mode="mode-table">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:colspec" mode="mode-table">
    <!-- Not sure whether we should generate something... -->
    <!--<col>
      <xsl:if test="exists(@colwidth)">
        <xsl:attribute name="width" select="@colwidth"/>
      </xsl:if>
      <xsl:call-template name="copy-id"/>
    </col>-->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:thead" mode="mode-table">
    <thead>
      <xsl:call-template name="copy-id"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="in-table-header" as="xs:boolean" select="true()" tunnel="true"/>
      </xsl:apply-templates>
    </thead>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:tbody" mode="mode-table">
    <tbody>
      <xsl:call-template name="copy-id"/>
      <xsl:apply-templates mode="#current"/>
    </tbody>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:row" mode="mode-table">
    <tr>
      <xsl:call-template name="copy-id"/>
      <xsl:apply-templates mode="#current"/>
    </tr>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:entry" mode="mode-table">
    <xsl:param name="in-table-header" as="xs:boolean" required="false" select="false()" tunnel="true"/>
    <xsl:element name="{if ($in-table-header) then 'th' else 'td'}">
      <xsl:call-template name="copy-id">
        <xsl:with-param name="create-anchor" select="true()"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="empty(db:para)">
          <!-- No surrounding <para> or so it seems, create one: -->
          <xsl:variable name="contents-in-para" as="element(db:para)">
            <db:para>
              <xsl:sequence select="node()"/>
            </db:para>
          </xsl:variable>
          <xsl:apply-templates select="$contents-in-para"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="db:*"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

  </xsl:template>

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
    <xsl:variable name="referenced-element" as="element()*" select="key($id-index-name, $id, $original-document)"/>
    <xsl:variable name="roles" as="xs:string*" select="xtlc:str2seq(@role)"/>
    <xsl:variable name="do-capitalize" as="xs:boolean" select="'capitalize' = $roles"/>

    <xsl:if test="count($referenced-element) gt 1">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('Id occurs ', count($referenced-element), ' times: ', xtlc:q($id))"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="exists($referenced-element)">
        <a href="#{$id}" class="{local-name(.)}">
          <xsl:choose>
            <xsl:when test="exists($referenced-element/@xreflabel)">
              <xsl:value-of select="$referenced-element/@xreflabel"/>
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
              <xsl:value-of select="$referenced-element/@number"/>
              <xsl:text>&#160;</xsl:text>
              <xsl:value-of select="normalize-space($referenced-element/db:title)"/>
            </xsl:when>
            <xsl:when
              test="$referenced-element/self::db:figure[exists(@number)] or $referenced-element/self::db:table[exists(@number)] or
                $referenced-element/self::db:example[exists(@number)]">
              <xsl:value-of select="local:xref-capitalize(local-name($referenced-element), $do-capitalize)"/>
              <xsl:text>&#160;</xsl:text>
              <xsl:value-of select="$referenced-element/@number"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="local:xref-capitalize(local-name($referenced-element), $do-capitalize)"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="insert-error">
          <xsl:with-param name="msg-parts" select="('Referenced linkend id ', xtlc:q(@linkend), ' not found')"/>
          <xsl:with-param name="block" select="false()"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:link" mode="mode-inline">

    <xsl:variable name="roles" as="xs:string*" select="xtlc:str2seq(normalize-space(@role))"/>
    <xsl:variable name="href" as="xs:string?">
      <xsl:choose>
        <xsl:when test="exists(@xlink:href)">
          <xsl:sequence select="@xlink:href"/>
        </xsl:when>
        <xsl:when test="exists(@linkend)">
          <xsl:variable name="id" as="xs:string" select="@linkend"/>
          <xsl:variable name="referenced-element" as="element()*" select="key($id-index-name, $id, $original-document)"/>
          <xsl:choose>
            <xsl:when test="count($referenced-element) eq 1">
              <xsl:sequence select="'#' || @linkend"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:choose>
      <xsl:when test="exists($href)">
        <a href="{$href}">
          <xsl:if test="'newpage' = $roles">
            <xsl:attribute name="target" select="'_blank'"/>
          </xsl:if>
          <xsl:call-template name="handle-inline-text">
            <xsl:with-param name="text" select="if ((normalize-space(.) eq '') and empty(*)) then (@xlink:href, @linkend)[1] else ()"/>
          </xsl:call-template>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="insert-error">
          <xsl:with-param name="msg-parts" select="('Referenced linkend id ', xtlc:q(@linkend), ' not found or multiple')"/>
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

    <xsl:variable name="roles" as="xs:string*" select="xtlc:str2seq(normalize-space(@role))"/>
    <xsl:variable name="bold" as="xs:boolean" select="'bold' =  $roles"/>
    <xsl:variable name="underline" as="xs:boolean" select="'underline' = $roles"/>
    <xsl:variable name="italic" as="xs:boolean" select="'italic' = $roles"/>

    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="bold" select="$bold"/>
      <xsl:with-param name="underline" select="$underline"/>
      <xsl:with-param name="italic" select="$italic or (not($bold) and not($underline) and not($italic))"/>
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

  <xsl:template match="db:inlinemediaobject" mode="mode-inline">
    <xsl:variable name="imagedata" as="element(db:imagedata)" select="(.//db:imagedata)[1]"/>
    <img src="{$imagedata/@fileref}" class="{local-name(.)}">
      <xsl:copy-of select="$imagedata/@width, $imagedata/@height"/>
      <xsl:call-template name="copy-id"/>
    </img>
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
    <xsl:param name="base-class" as="xs:string" required="false" select="local-name(.)"/>
    <xsl:param name="contents" as="node()*" required="no" select="node()"/>
    <xsl:param name="text" as="xs:string?" required="no" select="()"/>
    <!-- When $text is specified, $contents is ignored. -->
    <xsl:param name="bold" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="italic" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="underline" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="fixed-width" as="xs:boolean" required="no" select="false()"/>

    <xsl:variable name="class-components" as="xs:string*">
      <xsl:sequence select="$base-class"/>
      <xsl:if test="$bold">
        <xsl:sequence select="'bold'"/>
      </xsl:if>
      <xsl:if test="$italic">
        <xsl:sequence select="'italic'"/>
      </xsl:if>
      <xsl:if test="$underline">
        <xsl:sequence select="'underline'"/>
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
      <xsl:attribute name="class" select="string-join($class-components, ' ')"/>
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

  <xsl:template match="comment() | processing-instruction()" mode="#all" priority="-1000">
    <!-- Ignore... -->
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

  <xsl:template name="copy-id">
    <xsl:param name="elm" as="element()" required="no" select="."/>
    <xsl:param name="create-anchor" as="xs:boolean" required="false" select="false()"/>
    <xsl:param name="force" as="xs:boolean" required="false" select="false()"/>

    <xsl:variable name="id" as="xs:string?" select="$elm/@xml:id"/>
    <xsl:if test="exists($id) and ($force or ($id = $all-linkend-references))">
      <xsl:attribute name="id" select="$id"/>
      <xsl:if test="$create-anchor">
        <a name="{$id}">
          <!-- Add some bogus comment contents to avoid annoying browser behavior: -->
          <xsl:comment/>
        </a>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="comment() | processing-instruction()">
    <!-- Ignore -->
  </xsl:template>

</xsl:stylesheet>
