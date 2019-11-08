<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:dgi="http://www.xtpxlib.nl/ns/xdoc/docgen-intermediate" xmlns:local="#local-X6yg5"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:db="http://docbook.org/ns/docbook" xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--~	
    Turns the docgen intermediate format into (almost) DocBook.
    
    Parts that must be checked for Markdown are wrapped inside xdoc:MARKDOWN elements.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- DECLARATIONS: -->

  <xsl:variable name="href-in" as="xs:string" select="/*/@href"/>
  <xsl:variable name="filename" as="xs:string" select="xtlc:href-name($href-in)"/>

  <xsl:variable name="type-id" as="xs:string" select="/*/@type-id"/>
  <xsl:variable name="filecomponents" as="xs:integer" select="xtlc:str2int(/*/@filecomponents, 0)"/>

  <xsl:variable name="standard-title" as="xs:string" select="concat($filename, ' documentation')"/>

  <xsl:variable name="dt-format" as="xs:string" select="$xtlc:default-dt-format-nl"/>

  <xsl:variable name="href-docgen-types" as="xs:string" select="'../data/docgen-types.xml'"/>
  <xsl:variable name="type-translations" as="element(docgen-type)*" select="doc($href-docgen-types)/*/docgen-type"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">
    <xsl:apply-templates select="/*"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/dgi:document">
    <!-- Put everything in a group since we're going to create multiple elements and need a root element. This element will be removed later. -->
    <xdoc:GROUP>

      <!-- Display the filename if requested: -->
      <xsl:variable name="href-normalized" as="xs:string" select="xtlc:href-protocol-remove(xtlc:href-canonical($href-in))"/>
      <xsl:variable name="file-display" as="xs:string?">
        <xsl:choose>
          <xsl:when test="$filecomponents lt 0">
            <xsl:sequence select="()"/>
          </xsl:when>
          <xsl:when test="$filecomponents eq 0">
            <xsl:sequence select="$href-normalized"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="href-components" as="xs:string*" select="tokenize($href-normalized, '/')"/>
            <xsl:sequence select="string-join($href-components[position() gt (last() - $filecomponents)], '/')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="exists($file-display)">
        <para role="keep-with-next">File: <code>{ $file-display }</code></para>
      </xsl:if>

      <!-- Main documentation: -->
      <xsl:call-template name="documentation-to-docbook"/>

      <!-- Namespaces: -->
      <xsl:call-template name="namespaces-to-docbook"/>

      <!-- Global parameters: -->
      <xsl:call-template name="parameters-to-docbook">
        <xsl:with-param name="id" select="local:get-id('global')"/>
        <xsl:with-param name="title" select="'Global parameters in ' || $filename"/>
      </xsl:call-template>

      <!-- Objects ToC: -->
      <xsl:variable name="object-entries" as="element(dgi:object)*" select="dgi:objects/dgi:object"/>
      <xsl:variable name="add-title" as="xs:boolean" select="xtlc:str2bln(dgi:objects/@title, true())"/>
      <xsl:if test="exists($object-entries)">
        <xsl:for-each-group select="$object-entries" group-by="@type-id">
          <xsl:sort select="local:type-to-priority(current-grouping-key())" order="descending"/>
          <table xml:id="{local:get-id(('toc', current-grouping-key()))}">
            <xsl:if test="not($add-title)">
              <xsl:attribute name="role" select="'nonumber'"/>
            </xsl:if>
            <title>
              <xsl:if test="$add-title">
                <xsl:value-of select="local:type-to-description(current-grouping-key()) || 's in ' || $filename"/>
              </xsl:if>
            </title>
            <tgroup cols="2">
              <!-- Remark: We would like to make the first column flexible width (with role="code-width-cm:..."), but that doesn’t work here 
                since the contents of the column sometimes comes from an <xref> and is therefore generated... -->
              <colspec colwidth="5cm"/>
              <colspec/>
              <thead>
                <row>
                  <entry>{ local:type-to-description(current-grouping-key()) }</entry>
                  <entry>Description</entry>
                </row>
              </thead>
              <tbody>
                <xsl:for-each select="current-group()">
                  <xsl:sort select="@name"/>
                  <row>
                    <entry>
                      <code>
                        <xsl:choose>
                          <xsl:when test="local:object-has-more-info(.)">
                            <xref linkend="{local:get-object-id(.)}" role="text"/>
                          </xsl:when>
                          <xsl:otherwise>{ @name }</xsl:otherwise>
                        </xsl:choose>
                      </code>
                    </entry>
                    <entry>
                      <xdoc:MARKDOWN>{ local:header-documentation-line(., '') }</xdoc:MARKDOWN>
                    </entry>
                  </row>
                </xsl:for-each>
              </tbody>
            </tgroup>
          </table>
        </xsl:for-each-group>
      </xsl:if>

      <!-- Object detail information: -->
      <xsl:for-each select="$object-entries[local:object-has-more-info(.)]">
        <xsl:sort select="@name"/>
        <xsl:call-template name="object-to-docbook"/>
      </xsl:for-each>

    </xdoc:GROUP>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:type-to-description" as="xs:string">
    <xsl:param name="type-id" as="xs:string"/>

    <xsl:variable name="docgen-type-elm" as="element(docgen-type)?" select="$type-translations[@type-id eq $type-id]"/>
    <xsl:choose>
      <xsl:when test="exists($docgen-type-elm)">
        <xsl:value-of select="normalize-space($docgen-type-elm)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat('?', $type-id, '?')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:type-to-priority" as="xs:integer">
    <xsl:param name="type-id" as="xs:string"/>

    <xsl:variable name="docgen-type-elm" as="element(docgen-type)?" select="$type-translations[@type-id eq $type-id]"/>
    <xsl:choose>
      <xsl:when test="exists($docgen-type-elm)">
        <xsl:value-of select="xs:integer($docgen-type-elm/@priority)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="-10000"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:header-documentation-line" as="xs:string">
    <xsl:param name="elm" as="element()"/>
    <xsl:param name="prefix" as="xs:string?"/>

    <xsl:variable name="line" as="xs:string?" select="$elm/dgi:documentation/dgi:line[1]/string()"/>
    <xsl:sequence select="if (exists($line)) then concat(string($prefix), $line) else ''"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:object-has-more-info" as="xs:boolean">
    <xsl:param name="object" as="element(dgi:object)"/>

    <xsl:sequence select="(count($object/dgi:documentation/dgi:line) gt 1) or exists($object/dgi:parameters/dgi:parameter)"/>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- HTML GENERIC SUPPORT: -->

  <xsl:template name="documentation-to-docbook">
    <!-- Generate something that will be transformed from Markdown into Docbook in a later stage of the pipeline: -->
    <xsl:param name="elm" as="element()?" required="no" select="."/>

    <xsl:variable name="lines" as="element(dgi:line)*" select="$elm/dgi:documentation/dgi:line"/>
    <xdoc:MARKDOWN>
      <xsl:value-of select="string-join($lines/string(), '&#10;')"/>
    </xdoc:MARKDOWN>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="namespaces-to-docbook">
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <xsl:variable name="namespace-entries" as="element(dgi:namespace)*" select="$elm/dgi:namespaces/dgi:namespace"/>
    <xsl:if test="exists($namespace-entries)">
      <xsl:variable name="has-description" as="xs:boolean" select="some $ne in $namespace-entries satisfies (normalize-space($ne) ne '')"/>

      <table xml:id="{xtlc:str2id(local:get-id('namespaces'))}">
        <title>Namespaces in { $filename }</title>
        <tgroup cols="{if ($has-description) then 3 else 2}">
          <colspec role="code-width-cm:1-4"/>
          <colspec/>
          <xsl:if test="$has-description">
            <colspec/>
          </xsl:if>
          <thead>
            <row>
              <entry>Prefix</entry>
              <entry>Namespace</entry>
              <xsl:if test="$has-description">
                <entry>Description:</entry>
              </xsl:if>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$namespace-entries">
              <row>
                <entry>
                  <code role="code-width-limited">{ @prefix }</code>
                </entry>
                <entry>
                  <code>{ @uri }</code>
                </entry>
                <xsl:if test="$has-description">
                  <xsl:call-template name="documentation-to-docbook"/>
                </xsl:if>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="parameters-to-docbook">
    <xsl:param name="elm" as="element()" required="no" select="."/>
    <xsl:param name="id" as="xs:string?" required="false" select="()"/>
    <xsl:param name="title" as="xs:string?" required="false" select="()"/>

    <xsl:for-each select="$elm/dgi:parameters[exists(dgi:parameter)]">
      <xsl:variable name="parameter-entries" as="element(dgi:parameter)*" select="dgi:parameter"/>
      <xsl:variable name="typename" as="xs:string" select="(@typename, 'parameter')[1]"/>
      <xsl:variable name="add-title" as="xs:boolean" select="xtlc:str2bln(@title, true()) and exists($title)"/>
      <xsl:variable name="has-type-info" as="xs:boolean" select="exists($parameter-entries/@type)"/>
      <xsl:variable name="has-required-info" as="xs:boolean" select="exists($parameter-entries/@required)"/>
      <xsl:variable name="has-default-info" as="xs:boolean" select="exists($parameter-entries/@default)"/>
      <xsl:variable name="nr-of-columns" as="xs:integer"
        select="2 + (if ($has-type-info) then 1 else 0) + (if ($has-required-info) then 1 else 0) + (if ($has-default-info) then 1 else 0)"/>

      <table>
        <xsl:if test="not($add-title)">
          <xsl:attribute name="role" select="'nonumber'"/>
        </xsl:if>
        <xsl:if test="exists($id)">
          <xsl:attribute name="xml:id" select="$id || '-' || $typename || 's'"/>
        </xsl:if>
        <title>{ if ($add-title) then $title else () }</title>
        <tgroup cols="{$nr-of-columns}">
          <colspec role="code-width-cm:1.5-4"/>
          <xsl:if test="$has-type-info">
            <colspec role="code-width-cm:1-4"/>
          </xsl:if>
          <xsl:if test="$has-required-info">
            <colspec role="code-width-cm:1.2-4"/>
          </xsl:if>
          <xsl:if test="$has-default-info">
            <colspec role="code-width-cm:1-4"/>
          </xsl:if>
          <colspec/>
          <thead>
            <row>
              <entry>{ xtlc:capitalize($typename) }</entry>
              <xsl:if test="$has-type-info">
                <entry>Type</entry>
              </xsl:if>
              <xsl:if test="$has-required-info">
                <entry>Required</entry>
              </xsl:if>
              <xsl:if test="$has-default-info">
                <entry>Default</entry>
              </xsl:if>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$parameter-entries">
              <row>
                <entry>
                  <code role="code-width-limited">{ @name }</code>
                </entry>
                <xsl:if test="$has-type-info">
                  <entry>
                    <code role="code-width-limited">{ @type }</code>
                  </entry>
                </xsl:if>
                <xsl:if test="$has-required-info">
                  <entry>
                    <code role="code-width-limited">{ @required }</code>
                  </entry>
                </xsl:if>
                <xsl:if test="$has-default-info">
                  <entry>
                    <code role="code-width-limited">{ @default }</code>
                  </entry>
                </xsl:if>
                <entry>
                  <xsl:call-template name="documentation-to-docbook"/>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="object-to-docbook">
    <xsl:param name="object" as="element(dgi:object)" required="no" select="."/>

    <xsl:for-each select="$object">
      <xsl:variable name="type-description" as="xs:string" select="local:type-to-description(@type-id)"/>
      <xsl:variable name="typename-for-title" as="xs:string" select="($object//@typename, 'parameter')[1]"/>
      <bridgehead xml:id="{local:get-object-id(.)}" xreflabel="{@name}">
        <xsl:value-of select="$type-description"/>
        <xsl:text>: </xsl:text>
        <code>{ @name }</code>
        <xsl:if test="normalize-space(@type) ne ''">
          <xsl:text> =&gt; </xsl:text>
          <code>{ @type }</code>
        </xsl:if>
      </bridgehead>
      <xsl:call-template name="documentation-to-docbook"/>
      <xsl:call-template name="parameters-to-docbook">
        <xsl:with-param name="title" select="xtlc:capitalize($typename-for-title) || 's of ' || @name"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-object-id" as="xs:string">
    <xsl:param name="object" as="element(dgi:object)"/>
    <xsl:sequence select="local:get-id(($object/@type-id, $object/@name, string(count($object/dgi:parameters/dgi:parameter))))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-id" as="xs:string">
    <xsl:param name="suffixes" as="xs:string+"/>
    <xsl:sequence select="xtlc:str2id(string-join(($filename, $suffixes), '-'))"/>
  </xsl:function>

</xsl:stylesheet>
