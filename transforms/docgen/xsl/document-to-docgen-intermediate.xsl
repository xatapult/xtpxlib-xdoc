<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local-u67gh"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns="http://www.xtpxlib.nl/ns/xdoc/docgen-intermediate" xmlns:dgi="http://www.xtpxlib.nl/ns/xdoc/docgen-intermediate"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--~
    Converts an incoming XML document into the docgen intermediate format. From this we can easily generate the DocBook for the
    documentation.
    
    There is a schema for this format in ../xsd/docgen-intermediate.xsd.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="element-documentation-start" as="xs:string" select="'~'">
    <!-- A comment that starts with this string is considered the description for its parent element. -->
  </xsl:variable>

  <xsl:variable name="local-namespace-prefixes" as="xs:string+" select="('local')">
    <!-- Anything in namespaces that uses one of these prefixes are considered local and ignored. -->
  </xsl:variable>

  <xsl:variable name="document-href" as="xs:string">
    <!-- The reference to the main document. -->
    <xsl:variable name="href-raw" as="xs:string">
      <xsl:choose>
        <xsl:when test="exists(/xdoc:transform)">
          <xsl:sequence select="/xdoc:transform/*[1]/@xml:base"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="base-uri(/*)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="xtlc:href-canonical($href-raw)"/>
  </xsl:variable>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <document href="{$document-href}" timestamp="{current-dateTime()}">
      <!-- Remark: the construction below is to keep things working when we run the stylesheet on its own, outside an xdoc context. -->
      <xsl:choose>
        <xsl:when test="exists(/xdoc:transform)">
          <xsl:copy-of select="/xdoc:transform/@filecomponents"/>
          <xsl:apply-templates select="/xdoc:transform/*[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="/*[1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </document>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SELECT ON TYPE OF DOCUMENT BY ROOT ELEMENT: -->

  <xsl:template match="xsl:stylesheet">
    <xsl:attribute name="type-id" select="if (ends-with(base-uri(.), '.mod.xsl')) then 'xslmod' else 'xsl'"/>
    <xsl:call-template name="get-element-documentation"/>
    <xsl:call-template name="process-important-namespaces">
      <xsl:with-param name="probable-names" select="xsl:*/@name/string()"/>
    </xsl:call-template>
    <xsl:call-template name="xsl-gather-parameters"/>
    <xsl:call-template name="xsl-gather-objects"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="p:library">
    <xsl:attribute name="type-id" select="'xplmod'"/>
    <xsl:call-template name="xpl-get-element-documentation"/>
    <xsl:call-template name="process-important-namespaces">
      <xsl:with-param name="probable-names" select="p:declare-step/@type/string()"/>
    </xsl:call-template>
    <xsl:call-template name="xpl-gather-library-objects"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="p:declare-step">
    <xsl:attribute name="type-id" select="'xpl'"/>
    <xsl:call-template name="xpl-get-element-documentation"/>
    <xsl:call-template name="xpl-gather-parameters"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xs:schema">
    <xsl:attribute name="type-id" select="'xsd'"/>
    <xsl:call-template name="xsd-get-element-documentation"/>
    <xsl:call-template name="xsd-gather-objects"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" priority="-1">
    <xsl:attribute name="type-id" select="'xml'"/>
    <xsl:call-template name="get-element-documentation"/>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- XSL SUPPORT: -->

  <xsl:template name="xsl-gather-objects" as="element(dgi:objects)?">
    <!-- Gathers all the information about the global objects in an xsl stylsheet. 
      When any found, creates an <objects> element ssuitable for inclusion in the final document.
    -->
    <xsl:param name="root" as="element(xsl:stylesheet)" required="no" select="."/>

    <!-- Gather applicable objects: -->
    <xsl:variable name="objects" as="element()*" select="$root/xsl:*[exists(@name)][local:object-name-is-relevant(string(@name))]"/>

    <!-- Process all objects: -->
    <xsl:if test="exists($objects)">
      <objects>
        <xsl:for-each select="$objects">
          <xsl:variable name="object" as="element()" select="."/>
          <xsl:variable name="name" as="xs:string" select="if (local-name($object) eq 'variable') then concat('$', @name) else @name"/>
          <object type-id="{local-name($object)}" name="{$name}">
            <xsl:if test="normalize-space(@as) ne ''">
              <xsl:attribute name="type" select="@as"/>
            </xsl:if>
            <xsl:call-template name="get-element-documentation"/>
            <xsl:call-template name="xsl-gather-parameters"/>
          </object>
        </xsl:for-each>
      </objects>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xsl-gather-parameters" as="element(dgi:parameters)?">
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <xsl:variable name="is-function" as="xs:boolean" select="exists($elm/self::xsl:function)"/>
    <xsl:if test="exists($elm/xsl:param)">
      <parameters>
        <xsl:for-each select="$elm/xsl:param">
          <parameter name="{@name}">

            <xsl:if test="exists(@as)">
              <xsl:attribute name="type" select="@as"/>
            </xsl:if>
            <xsl:if test="exists(@select)">
              <xsl:attribute name="default" select="@select"/>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="exists(@required)">
                <xsl:attribute name="required" select="local:yes-no-to-boolean(@required)"/>
              </xsl:when>
              <xsl:when test="not($is-function)">
                <xsl:attribute name="required" select="false()"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- There is no required information avialable... -->
              </xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="get-element-documentation"/>

          </parameter>
        </xsl:for-each>
      </parameters>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- XPROC SUPPORT: -->

  <xsl:template name="xpl-get-element-documentation">
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <xsl:variable name="elm-documentation" as="element(p:documentation)?" select="($elm/p:documentation[normalize-space(.) ne ''])[1]"/>
    <xsl:if test="exists($elm-documentation)">
      <documentation>
        <xsl:call-template name="handle-multiline-text">
          <xsl:with-param name="in" select="string($elm-documentation)"/>
        </xsl:call-template>
      </documentation>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xpl-gather-library-objects">
    <xsl:param name="root" as="element(p:library)" required="no" select="."/>

    <!-- Gather applicable objects: -->
    <xsl:variable name="objects" as="element(p:declare-step)*"
      select="$root/p:declare-step[exists(@type)][local:object-name-is-relevant(string(@type))]"/>

    <!-- Process all objects: -->
    <xsl:where-populated>
      <objects>
        <xsl:for-each select="$objects">
          <xsl:variable name="object" as="element()" select="."/>
          <object type-id="xplstep" name="{@type}">
            <xsl:call-template name="xpl-get-element-documentation"/>
            <xsl:call-template name="xpl-gather-parameters"/>
          </object>
        </xsl:for-each>
      </objects>
    </xsl:where-populated>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xpl-gather-parameters">
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <!-- Ports: -->
    <xsl:where-populated>
      <parameters typename="port" title="false">
        <xsl:for-each select="$elm/(p:input | p:output)">
          <parameter name="{@port}">
            <xsl:variable name="port-type" as="xs:string" select="local-name(.)"/>
            <xsl:variable name="is-only-definition-of-this-type" as="xs:boolean"
              select="empty(preceding-sibling::*[local-name() eq $port-type]) and empty(following-sibling::*[local-name() eq $port-type])"/>
            <xsl:variable name="is-primary" as="xs:boolean" select="xtlc:str2bln(@primary, false()) or $is-only-definition-of-this-type"/>
            <xsl:attribute name="type" select="$port-type || (if ($is-primary) then ', primary' else ())"/>
            <xsl:call-template name="xpl-get-element-documentation"/>
          </parameter>
        </xsl:for-each>
      </parameters>
    </xsl:where-populated>

    <!-- Options: -->
    <xsl:where-populated>
      <parameters typename="option" title="false">
        <xsl:for-each select="$elm/p:option">
          <parameter name="{@name}">
            <xsl:copy-of select="@required"/>
            <xsl:if test="exists(@select)">
              <xsl:attribute name="default" select="@select"/>
            </xsl:if>
            <xsl:call-template name="xpl-get-element-documentation"/>
          </parameter>
        </xsl:for-each>
      </parameters>
    </xsl:where-populated>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- XSD SUPPORT: -->

  <xsl:template name="xsd-gather-objects" as="element(dgi:objects)?">
    <!-- Gathers all the information about the global objects in a schema. 
      When any found, creates an <objects> element suitable for inclusion in the final document.
    -->
    <xsl:param name="root" as="element(xs:schema)" required="no" select="."/>

    <!-- Gather applicable objects: -->
    <xsl:variable name="objects" as="element()*" select="$root/xs:element"/>

    <!-- Process all objects: -->
    <xsl:if test="exists($objects)">
      <objects title="false">
        <xsl:for-each select="$objects">
          <xsl:variable name="object" as="element()" select="."/>
          <object type-id="{local-name($object)}" name="{@name}">
            <xsl:call-template name="xsd-get-element-documentation"/>
          </object>
        </xsl:for-each>
      </objects>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xsd-get-element-documentation">
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <xsl:variable name="elm-documentation" as="element(xs:documentation)?" select="($elm/xs:annotation/xs:documentation[normalize-space(.) ne ''])[1]"/>
    <xsl:if test="exists($elm-documentation)">
      <documentation>
        <xsl:call-template name="handle-multiline-text">
          <xsl:with-param name="in" select="string($elm-documentation)"/>
        </xsl:call-template>
      </documentation>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- GENERIC SUPPORT: -->

  <xsl:template name="process-important-namespaces" as="element(dgi:namespaces)?">
    <!-- Gathers all the information about important namespaces. Namespaces are important when they are used in templates, functions and names
      of other globally visible objects (like variables, attribute-sets, etc.). 
      The namespace prefixes in $local-namespace-prefixes are considered local and not processed.
      When found, creates a <namespaces> element suitable for inclusion in the final document. 
      All important namespace prefixes *must* be defined on the root element!
    -->
    <xsl:param name="root" as="element()" required="no" select="."/>
    <xsl:param name="probable-names" as="xs:string*" required="yes"/>

    <!-- Gather all the applicable namespace prefixes: -->
    <xsl:variable name="important-namespace-prefixes" as="xs:string*"
      select="distinct-values(for $name in $probable-names[local:object-name-is-relevant(.)] return substring-before($name, ':'))"/>

    <!-- Process these into a <namespaces> structure: -->
    <xsl:if test="exists($important-namespace-prefixes)">
      <namespaces>
        <xsl:for-each select="$important-namespace-prefixes">
          <xsl:variable name="prefix" as="xs:string" select="."/>
          <xsl:variable name="uri" as="xs:string" select="string(namespace-uri-for-prefix($prefix, $root))"/>
          <xsl:if test="$uri eq ''">
            <xsl:call-template name="xtlc:raise-error">
              <xsl:with-param name="msg-parts"
                select="('Document &quot;', $document-href, '&quot;: Namespace prefix &quot;', $prefix, '&quot; not defined on root element')"/>
            </xsl:call-template>
          </xsl:if>

          <namespace prefix="{$prefix}" uri="{$uri}">
            <!-- Although the docgen schema allows a namespace to have documention we have no means (yet) to define this. -->
          </namespace>

        </xsl:for-each>
      </namespaces>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="get-element-documentation">
    <!-- Tries to find the documentation comment for this element (a documentation comment starts with the string $element-documentation-start)
      and extracts this into a <documentation> element. -->
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <xsl:variable name="documentation-comment" as="comment()?"
      select="$elm/comment()[starts-with(., $element-documentation-start)]
      [normalize-space(substring-after(., $element-documentation-start)) ne '']"/>
    <xsl:if test="exists($documentation-comment)">
      <documentation>
        <xsl:call-template name="handle-multiline-text">
          <xsl:with-param name="in" select="substring-after($documentation-comment, $element-documentation-start)"/>
        </xsl:call-template>
      </documentation>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="handle-multiline-text">
    <xsl:param name="in" as="xs:string" required="yes"/>

    <!-- Seperate into lines but do not take end-whitespace into account:: -->
    <xsl:variable name="in-no-cr-characters" as="xs:string" select="replace($in, '&#x0d;', '')"/>
    <xsl:variable name="lines-raw" as="xs:string*" select="tokenize($in-no-cr-characters, '&#x0a;')"/>

    <!-- Remove leading and trailing empty lines: -->
    <xsl:variable name="lines" as="xs:string*">
      <xsl:for-each select="$lines-raw">
        <xsl:variable name="current-position" as="xs:integer" select="position()"/>
        <xsl:variable name="normalized-line" as="xs:string" select="normalize-space(.)"/>
        <xsl:choose>

          <!-- Non empty lines always pass: -->
          <xsl:when test="$normalized-line ne ''">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when
            test="($normalized-line eq '') and 
              (every $line in $lines-raw[position() = (1 to ($current-position - 1))] satisfies (normalize-space($line) eq ''))">
            <!-- No lines with content before, discard... -->
          </xsl:when>
          <xsl:when
            test="($normalized-line eq '') and 
              (every $line in $lines-raw[position() = (($current-position + 1) to count($lines-raw))] satisfies (normalize-space($line) eq ''))">
            <!-- No lines with content before, discard... -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <!-- Output the lines: -->
    <xsl:for-each select="$lines">

      <!-- Normalize the line and remove any leading underscores. Underscores will be replaced by indents (there seemed to be no other 
        way, since leading whitespace often contains tabs and it was very hard to compute how much the indent actually had to be. Therefore 
        we use the (ugly) idea of forcing whitespace by adding underscores at the beginning of a line. 
      -->
      <xsl:variable name="line-normalized" as="xs:string" select="normalize-space(.)"/>
      <xsl:variable name="line-normalized-no-prefix" as="xs:string" select="replace($line-normalized, '^_+', '')"/>
      <xsl:variable name="indent" as="xs:integer" select="string-length($line-normalized) - string-length($line-normalized-no-prefix)"/>

      <line>
        <xsl:if test="$indent gt 0">
          <xsl:attribute name="indent" select="$indent"/>
        </xsl:if>
        <xsl:value-of select="$line-normalized-no-prefix"/>
      </line>
    </xsl:for-each>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:leading-indent" as="xs:integer">
    <xsl:param name="in" as="xs:string"/>

    <xsl:sequence select="string-length($in) - string-length(replace($in, '^\s+', ''))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:yes-no-to-boolean" as="xs:boolean">
    <xsl:param name="yes-no" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$yes-no castable as xs:boolean">
        <xsl:sequence select="xs:boolean($yes-no)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$yes-no eq 'yes'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:object-name-is-relevant" as="xs:boolean">
    <xsl:param name="name" as="xs:string"/>

    <xsl:choose>
      <!-- Names in no namepsace are considered local and therefore not relevant: -->
      <xsl:when test="not(contains($name, ':'))">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <!-- Some namespace prefixes are considered local always: -->
      <xsl:when test="substring-before($name, ':') = $local-namespace-prefixes">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="true()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="xdoc:warning-prevention-template"/>
  
</xsl:stylesheet>
