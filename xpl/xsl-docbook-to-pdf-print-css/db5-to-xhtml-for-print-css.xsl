<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*	
    Turns the db5 (xtpxlib-xdoc dialect) into XHTML for processing by a Print CSS processor.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <xsl:mode on-no-match="fail"/>
  <xsl:mode name="mode-block" on-no-match="fail"/>
  <xsl:mode name="mode-table" on-no-match="fail"/>
  <xsl:mode name="mode-inline" on-no-match="fail"/>

  <xsl:variable name="id-index-name" as="xs:string" select="'id-index'" static="true"/>
  <xsl:key _name="{$id-index-name}" match="db:*" use="@xml:id"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="print-css-processor" as="xs:string" required="yes"/>
  <xsl:param name="href-css" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL VARIABLES: -->

  <xsl:variable name="original-document" as="document-node()" select="/"/>

  <!-- The contents of the following elements is always considered to be inline: -->
  <xsl:variable name="block-to-inline-element-names" as="xs:string+" select="('para', 'title')"/>

  <!-- Add an xml:space="preserve" on these elements: -->
  <xsl:variable name="add-preserve-space-element-names" as="xs:string+" select="('programlisting', 'code', 'literal', 'tag')"/>

  <!-- Automatic element name translations: -->
  <xsl:variable name="auto-name-translations" as="map(xs:string, xs:string)" select="map{
      (: Block: :)
      'title': 'h1',
      'subtitle': 'h2',
      'itemizedlist': 'ul',
      'simplelist': 'ul',
      'orderedlist': 'ol',
      'listitem': 'li',
      'variablelist': 'dl',
      (: Inline: :)
      'literal': 'code',
      'code': 'code'
    }"/>


  <!-- ================================================================== -->
  <!-- MAIN TEMPLATE: -->

  <xsl:template match="/">
    <html>
      <xsl:comment> == Print CSS input file for the {$print-css-processor} processor == </xsl:comment>
      <xsl:comment> == Generated: {current-dateTime()} == </xsl:comment>
      <head>
        <link rel="stylesheet" type="text/css" href="{$href-css}"/>
      </head>
      <xsl:apply-templates select="db:*" mode="mode-block"/>
    </html>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- BLOCK MODE:  -->

  <xsl:template match="/db:*" mode="mode-block">
    <body>
      <xsl:call-template name="add-base-attributes"/>
      <xsl:apply-templates select="db:*" mode="#current"/>
    </body>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:*" mode="mode-block">

    <xsl:choose>
      <xsl:when test="local:is-block-level-element(.)">
        <xsl:element name="{local:get-output-element-name(., 'div')}">
          <xsl:call-template name="add-base-attributes"/>
          <xsl:apply-templates select="db:*" mode="#current"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{local:get-output-element-name(., 'p')}">
          <xsl:call-template name="add-base-attributes"/>
          <xsl:apply-templates mode="mode-inline"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Variable lists: -->

  <xsl:template match="db:varlistentry" mode="mode-block">
    <!-- Just plod on... -->
    <xsl:apply-templates select="db:*" mode="#current"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:varlistentry/db:term" mode="mode-block">
    <dt>
      <xsl:call-template name="add-base-attributes"/>
      <xsl:apply-templates mode="mode-inline"/>
    </dt>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:varlistentry/db:listitem" mode="mode-block">
    <dd>
      <xsl:call-template name="add-base-attributes"/>
      <xsl:apply-templates select="db:*" mode="#current"/>
    </dd>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Images: -->

  <xsl:template match="db:mediaobject" mode="mode-block">
    <xsl:variable name="imagedata" as="element(db:imagedata)" select="(.//db:imagedata)[1]"/>
    <xsl:variable name="ref" as="xs:string" select="resolve-uri($imagedata/@fileref, base-uri(.))"/>
    <img src="{$ref}">
      <xsl:call-template name="add-base-attributes"/>
      <xsl:copy-of select="$imagedata/@width, $imagedata/@height"/>
    </img>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Non-empty text (not allowed in block mode): -->

  <xsl:template match="text()[normalize-space() ne '']" mode="mode-block mode-table">
    <xsl:call-template name="xtlc:raise-error">
      <xsl:with-param name="msg-parts" select="('Encountered non-empty text in block-mode: ', xtlc:q(.))"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- TABLES: -->

  <xsl:template match="db:table | db:informaltable" mode="mode-block">

    <xsl:variable name="original-table-element" as="element()" select="."/>

    <!-- Create a separate table for each tgroup: -->
    <xsl:for-each select="db:tgroup">
      <table>
        <xsl:call-template name="add-base-attributes">
          <xsl:with-param name="elm" select="$original-table-element"/>
          <xsl:with-param name="additional-classes" select="'cols-' || @cols"/>
        </xsl:call-template>

        <!-- Title becomes caption: -->
        <xsl:if test="normalize-space($original-table-element/db:title) ne ''">
          <xsl:apply-templates select="$original-table-element/db:title" mode="mode-table"/>
        </xsl:if>

        <!-- Check for colspecs: -->
        <xsl:where-populated>
          <colgroup>
            <xsl:apply-templates select="db:colspec" mode="mode-table">
              <xsl:sort select="@colnum" data-type="number"/>
            </xsl:apply-templates>
          </colgroup>
        </xsl:where-populated>

        <!-- Contents: -->
        <xsl:apply-templates select="db:thead/db:row | db:tbody/db:row" mode="mode-table"/>

      </table>
    </xsl:for-each>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:title" mode="mode-table">
    <caption>
      <xsl:call-template name="add-base-attributes"/>
      <xsl:apply-templates mode="mode-inline"/>
    </caption>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:colspec" mode="mode-table">
    <col>
      <xsl:call-template name="add-base-attributes"/>
      <xsl:if test="exists(@colspan)">
        <xsl:attribute name="span" select="@colspan"/>
      </xsl:if>
    </col>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:row" mode="mode-table">
    <tr>
      <xsl:call-template name="add-base-attributes"/>
      <xsl:apply-templates select="db:entry" mode="#current"/>
    </tr>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:thead/db:row/db:entry" mode="mode-table">
    <th>
      <xsl:call-template name="add-base-attributes"/>
      <xsl:call-template name="handle-table-entry"/>
    </th>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:tbody/db:row/db:entry" mode="mode-table">
    <td>
      <xsl:call-template name="add-base-attributes"/>
      <xsl:call-template name="handle-table-entry"/>
    </td>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="handle-table-entry">
    <xsl:param name="entry" as="element(db:entry)" required="no" select="."/>
    <xsl:for-each select="$entry">
      <xsl:choose>
        <!-- Remark: This test is not good enough... but for now ok. -->
        <xsl:when test="empty(db:para)">
          <p class="para">
            <xsl:apply-templates mode="mode-inline"/>
          </p>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="db:*" mode="mode-block"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- INLINE MODE: -->

  <xsl:template match="text()" mode="mode-inline">
    <xsl:copy/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Tags: -->

  <xsl:template match="db:tag" mode="mode-inline">
    <xsl:variable name="class" as="xs:string" select="string((@class, 'element')[1])"/>
    <code>
      <xsl:call-template name="add-base-attributes">
        <xsl:with-param name="additional-classes" select="$class"/>
      </xsl:call-template>
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
    </code>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:*" mode="mode-inline">
    <xsl:element name="{local:get-output-element-name(., 'span')}">
      <xsl:call-template name="add-base-attributes"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:function name="local:get-output-element-name" as="xs:string">
    <xsl:param name="elm-in" as="element()"/>
    <xsl:param name="default-name" as="xs:string"/>

    <xsl:variable name="auto-translated-name" as="xs:string?" select="$auto-name-translations(local-name($elm-in))"/>
    <xsl:sequence select="($auto-translated-name, $default-name)[1]"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:is-block-level-element" as="xs:boolean">
    <xsl:param name="elm" as="element()"/>

    <xsl:variable name="elm-name" as="xs:string" select="local-name($elm)"/>
    <xsl:choose>
      <xsl:when test="$elm-name = $block-to-inline-element-names">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="contains-non-empty-text" as="xs:boolean"
          select="some $child-text-node in $elm/text() satisfies (normalize-space($child-text-node) ne '')"/>
        <xsl:sequence select="exists($elm/db:*) and not($contains-non-empty-text)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-base-attributes">
    <xsl:param name="elm" as="element()" required="no" select="."/>
    <xsl:param name="additional-classes" as="xs:string*" required="no" select="()"/>

    <!-- Take care of @class: -->
    <xsl:variable name="roles" as="xs:string*" select="tokenize(string($elm/@role), '\s+')[.]"/>
    <xsl:attribute name="class" select="string-join(distinct-values((local-name($elm), $roles, $additional-classes)), ' ')"/>

    <!-- Add an @id: -->
    <xsl:if test="exists($elm/@xml:id)">
      <xsl:attribute name="id" select="$elm/@xml:id"/>
    </xsl:if>

    <!-- Check for an explicit number: -->
    <xsl:if test="exists($elm/@number)">
      <xsl:attribute name="data-number" select="@number"/>
    </xsl:if>

    <!-- Check for preserve space: -->
    <xsl:if test="local-name($elm) = $add-preserve-space-element-names">
      <xsl:attribute name="xml:space" select="'preserve'"/>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="comment() | processing-instruction()" mode="#all">
    <!-- Ignore -->
  </xsl:template>

</xsl:stylesheet>
