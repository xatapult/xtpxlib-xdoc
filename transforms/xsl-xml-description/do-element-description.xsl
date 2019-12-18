<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local-zz55g" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:db="http://docbook.org/ns/docbook" xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Converts an XML element description to Docbook 5 (as an xdoc transformation)
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->
  <!-- GLOBALS: -->

  <xsl:variable name="xdoc-namespace" as="xs:string" select="'http://www.xtpxlib.nl/ns/xdoc'"/>
  <xsl:variable name="docbook-namespace" as="xs:string" select="'http://docbook.org/ns/docbook'"/>

  <xsl:variable name="global-root-elm" as="element()" select="/*"/>

  <xsl:variable name="newline" as="xs:string" select="'&#x0a;'"/>
  <xsl:variable name="ellipsis" as="xs:string" select="'&#x2026;'"/>

  <xsl:variable name="standard-coded-description-indent" as="xs:integer" select="2"/>
  <xsl:variable name="show-nr-of-enum-values-for-attribute-in-coded-description" as="xs:integer" select="3">
    <!-- The number of attribute enumeration values to show in the coded description (if there are more this will be followed by an ellipsis) -->
  </xsl:variable>

  <xsl:variable name="description-table-name-column-min-width-cm" as="xs:double" select="1.2"/>
  <xsl:variable name="description-table-name-column-max-width-cm" as="xs:double" select="4.0"/>
  <xsl:variable name="description-table-occurs-column-width-cm" as="xs:double" select="0.35"/>
  <xsl:variable name="description-table-type-column-width-cm" as="xs:double" select="3.5"/>

  <xsl:variable name="enums-table-value-column-min-width-cm" as="xs:double" select="0.8"/>
  <xsl:variable name="enums-table-value-column-max-width-cm" as="xs:double" select="2"/>

  <!-- ================================================================== -->

  <xsl:template match="/xdoc:transform">
    <!-- Because of how the transformation pipelines work, the actual element description always comes wrapped inside a <xdoc:transform> element: -->
    <xsl:variable name="element-description" as="element(xdoc:element-description)?" select="xdoc:element-description[1]"/>
    <xsl:choose>
      <xsl:when test="exists($element-description)">
        <xdoc:GROUP>
          <xsl:apply-templates select="$element-description"/>
        </xdoc:GROUP>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="'No xdoc:element-description element as root of an XML element description transformation'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xdoc:element-description">

    <!-- We start with the coded description: -->
    <xsl:call-template name="create-coded-description"/>

    <!-- Then output the general description: -->
    <xsl:call-template name="output-docbook-contents">
      <xsl:with-param name="encompassing-element" select="xdoc:description"/>
    </xsl:call-template>


    <!-- Attributes table: -->
    <xsl:call-template name="output-description-table">
      <xsl:with-param name="descriptions" select="xdoc:attribute"/>
      <xsl:with-param name="header" as="element()*" select="xdoc:attribute-table-header/*"/>
    </xsl:call-template>

    <!-- Elements table (remove doubles): -->
    <xsl:call-template name="output-description-table">
      <xsl:with-param name="descriptions" as="element(xdoc:element)*">
        <xsl:for-each-group select=".//xdoc:element" group-by="@name">
          <xsl:sequence select="current-group()[1]"/>
        </xsl:for-each-group>
      </xsl:with-param>
      <xsl:with-param name="header" as="element()*" select="xdoc:element-table-header/*"/>
    </xsl:call-template>


  </xsl:template>

  <!-- ================================================================== -->
  <!-- CODED DESCRIPTION: -->

  <xsl:template name="create-coded-description">
    <xsl:param name="element-description" as="element(xdoc:element-description)" required="no" select="."/>

    <xsl:for-each select="$element-description">
      <xsl:variable name="id" as="xs:string" select="(@id, xtlc:str2id(@name, 'element-'))[1]"/>
      <xsl:variable name="element-name" as="xs:string" select="@name"/>
      <xsl:variable name="attributes" as="element(xdoc:attribute)*" select="xdoc:attribute"/>
      <xsl:variable name="contents" as="element()*" select="xdoc:choice | xdoc:element | xdoc:element-placeholder"/>
      <xsl:variable name="additional-text-elm" as="element(xdoc:additional-text-coded-description)?" select="xdoc:additional-text-coded-description"/>
      <xsl:variable name="additional-text" as="xs:string" select="string($additional-text-elm)"/>
      <xsl:variable name="has-additional-text" as="xs:boolean" select="normalize-space($additional-text) ne ''"/>

      <!-- Create the formatted example: -->
      <programlisting xml:id="{$id}">

        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="$element-name"/>

        <xsl:choose>
          <!-- Nothing, just an empty element: -->
          <xsl:when test="empty($attributes) and empty($contents) and (normalize-space($additional-text) eq '')">
            <xsl:text>/&gt;</xsl:text>
          </xsl:when>

          <!-- We have contents... -->
          <xsl:otherwise>

            <!-- Attributes: -->
            <xsl:choose>
              <xsl:when test="empty($attributes)">
                <xsl:text>&gt;</xsl:text>
                <xsl:value-of select="$newline"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="indent" as="xs:integer" select="string-length($element-name) + 2"/>
                <xsl:for-each select="$attributes">
                  <xsl:if test="position() ne 1">
                    <xsl:value-of select="local:spaces($indent)"/>
                  </xsl:if>
                  <xsl:if test="position() eq 1">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                  <xsl:call-template name="output-code-description-attribute"/>
                  <xsl:if test="position() ne last()">
                    <xsl:value-of select="$newline"/>
                  </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="if (empty($contents) and not($has-additional-text)) then ' /&gt;' else concat(' &gt;', $newline)"/>
              </xsl:otherwise>
            </xsl:choose>

            <!-- Elements and choices: -->
            <xsl:apply-templates select="$contents" mode="mode-coded-description">
              <xsl:with-param name="indent" select="$standard-coded-description-indent"/>
            </xsl:apply-templates>

            <!-- Additional text: -->
            <xsl:if test="$has-additional-text">
              <xsl:call-template name="output-text-only-element">
                <xsl:with-param name="indent" select="$standard-coded-description-indent"/>
                <xsl:with-param name="elm" select="$additional-text-elm"/>
              </xsl:call-template>
            </xsl:if>

            <!-- Closing tag: -->
            <xsl:if test="exists($contents) or $has-additional-text">
              <xsl:text>&lt;/</xsl:text>
              <xsl:value-of select="$element-name"/>
              <xsl:text>&gt;</xsl:text>
            </xsl:if>

          </xsl:otherwise>
        </xsl:choose>
      </programlisting>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xdoc:element" mode="mode-coded-description">
    <xsl:param name="indent" as="xs:integer" required="yes"/>
    <xsl:param name="do-newline" as="xs:boolean" required="no" select="true()"/>

    <xsl:value-of select="local:spaces($indent)"/>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>&gt;</xsl:text>
    <xsl:value-of select="local:occurs-indicator(.)"/>
    <xsl:if test="$do-newline">
      <xsl:value-of select="$newline"/>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xdoc:element-placeholder" mode="mode-coded-description">
    <xsl:param name="indent" as="xs:integer" required="yes"/>
    <xsl:param name="do-newline" as="xs:boolean" required="no" select="false()"/>

    <xsl:call-template name="output-text-only-element">
      <xsl:with-param name="indent" select="$indent"/>
      <xsl:with-param name="elm" select="."/>
    </xsl:call-template>
    <xsl:if test="$do-newline">
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xdoc:choice" mode="mode-coded-description">
    <xsl:param name="indent" as="xs:integer" required="yes"/>

    <xsl:variable name="occurs" as="xs:string" select="(@occurs, '*')[1]"/>
    <xsl:variable name="opening-prefix" as="xs:string" select="'( '"/>
    <xsl:variable name="elements" as="element()+" select="xdoc:element | xdoc:element-placeholder"/>

    <xsl:value-of select="local:spaces($indent)"/>
    <xsl:value-of select="$opening-prefix"/>
    <!-- The first element is not indented (it follows the opening bracket): -->
    <xsl:apply-templates select="$elements[1]" mode="#current">
      <xsl:with-param name="indent" select="0"/>
      <xsl:with-param name="do-newline" select="false()"/>
    </xsl:apply-templates>
    <!-- Do the rest, if any, separated by pipes: -->
    <xsl:if test="count($elements) gt 1">
      <xsl:text> |</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:for-each select="$elements[position() gt 1]">
      <xsl:apply-templates select="." mode="#current">
        <xsl:with-param name="indent" select="$indent + string-length($opening-prefix)"/>
        <xsl:with-param name="do-newline" select="false()"/>
      </xsl:apply-templates>
      <xsl:if test="position() lt last()">
        <xsl:text> |</xsl:text>
        <xsl:value-of select="$newline"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:text> )</xsl:text>
    <xsl:value-of select="local:occurs-indicator(.)"/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-text-only-element">
    <xsl:param name="elm" as="element()?" required="yes"/>
    <xsl:param name="indent" as="xs:integer" required="yes"/>

    <xsl:variable name="comment-start" as="xs:string" select="'&lt;!-- '"/>
    <xsl:variable name="comment-end" as="xs:string" select="' --&gt;'"/>
    <xsl:variable name="additional-text" as="xs:string" select="normalize-space($elm)"/>
    <xsl:if test="$additional-text ne ''">
      <xsl:variable name="additional-text-parts" as="xs:string*" select="tokenize($additional-text, '\|')"/>
      <xsl:variable name="as-comment" as="xs:boolean" select="xtlc:str2bln($elm/@as-comment, false())"/>
      <xsl:value-of select="local:spaces($indent)"/>
      <xsl:choose>
        <xsl:when test="$as-comment">
          <xsl:value-of select="$comment-start"/>
          <xsl:value-of select="$additional-text-parts[1]"/>
          <xsl:for-each select="$additional-text-parts[position() ge 2]">
            <xsl:value-of select="$newline"/>
            <xsl:value-of select="local:spaces($indent + string-length($comment-start))"/>
            <xsl:value-of select="."/>
          </xsl:for-each>
          <xsl:value-of select="$comment-end"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$additional-text-parts[1]"/>
          <xsl:for-each select="$additional-text-parts[position() ge 2]">
            <xsl:value-of select="$newline"/>
            <xsl:value-of select="local:spaces($indent)"/>
            <xsl:value-of select="."/>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-code-description-attribute">
    <xsl:param name="attribute" as="element(xdoc:attribute)" required="no" select="."/>

    <xsl:for-each select="$attribute">

      <!-- Output attribute name and occurrences: -->
      <xsl:value-of select="@name"/>
      <xsl:if test="not(xtlc:str2bln(@required, false()))">
        <xsl:text>?</xsl:text>
      </xsl:if>

      <!-- Output type information (if any): -->
      <xsl:for-each select="xdoc:type">
        <xsl:text> = </xsl:text>
        <xsl:variable name="enums" as="element(xdoc:enum)*" select="xdoc:enum"/>
        <xsl:choose>
          <xsl:when test="exists($enums)">
            <!-- Remark: What we do here is that when there are many enums, we only show the first 
              $show-nr-of-enum-values-for-attribute-in-coded-description ones.
              Of course we could do elaborate stuff here by computing how much space there is on this line, but not now. 
              And anyway, we have no idea how wide this thing actually is, so this is made a parameter. -->
            <xsl:value-of
              select="string-join(for $e in $enums[position() le $show-nr-of-enum-values-for-attribute-in-coded-description] return xtlc:q($e/@value), ' | ')"/>
            <xsl:if test="count($enums) gt $show-nr-of-enum-values-for-attribute-in-coded-description">
              <xsl:text> </xsl:text>
              <xsl:value-of select="$ellipsis"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="(@base, @name)[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- ATTRIBUTES/ELEMENTS TABLE: -->

  <xsl:template name="output-description-table">
    <xsl:param name="descriptions" as="element()*" required="yes"/>
    <xsl:param name="header" as="element()*" required="no" select="()"/>

    <xsl:variable name="descriptions-to-use" as="element()*" select="$descriptions[xtlc:str2bln(@describe, true())]"/>
    <xsl:variable name="is-attributes" as="xs:boolean" select="exists($descriptions[1]/self::xdoc:attribute)"/>
    <xsl:variable name="has-type-info" as="xs:boolean" select="exists($descriptions-to-use/xdoc:type)"/>


    <!-- Output if anything left: -->
    <xsl:if test="exists($descriptions-to-use)">
      <para role="halfbreak"/>
      <xsl:call-template name="output-docbook-contents">
        <xsl:with-param name="elms" select="$header"/>
      </xsl:call-template>
      <!-- Add role to the name column so the final goal transformations (e.g. the one that creates XSL-FO) can compute the actual width. -->
      <xsl:variable name="name-column-role" as="xs:string"
        select="'code-width-cm:' || $description-table-name-column-min-width-cm || '-' || $description-table-name-column-max-width-cm"/>
      <table role="nonumber">
        <title/>
        <tgroup cols="{if ($has-type-info) then 4 else 3}">
          <colspec colname="name" role="{$name-column-role}"/>
          <colspec colname="occurrences" colwidth="{$description-table-occurs-column-width-cm}cm"/>
          <xsl:if test="$has-type-info">
            <colspec colname="type" colwidth="{$description-table-type-column-width-cm}cm"/>
          </xsl:if>
          <colspec colname="description"/>
          <thead>
            <row>
              <entry>
                <xsl:value-of select="if ($is-attributes) then 'Attribute' else 'Child element'"/>
              </entry>
              <entry>#</entry>
              <xsl:if test="$has-type-info">
                <entry>Type</entry>
              </xsl:if>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$descriptions-to-use">
              <row>
                <entry>
                  <code role="code-width-limited">
                    <xsl:value-of select="@name"/>
                  </code>
                </entry>
                <entry>
                  <para>
                    <xsl:choose>
                      <xsl:when test="$is-attributes">
                        <xsl:value-of select="if (xtlc:str2bln(@required, false())) then '1' else '?'"/>
                      </xsl:when>
                      <xsl:when test="exists(parent::xdoc:choice)">
                        <!-- In case this element is in a choice we take the occurrences of the choice. That is not exactly correct but better
                          than taking them from the element in a case like this... -->
                        <xsl:value-of select="(../@occurs, '1')[1]"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="(@occurs, '1')[1]"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </para>
                </entry>
                <xsl:if test="$has-type-info">
                  <entry>
                    <xsl:call-template name="output-type-info-in-description-table">
                      <xsl:with-param name="type" select="xdoc:type"/>
                      <xsl:with-param name="column-width-cm" select="$description-table-type-column-width-cm"/>
                    </xsl:call-template>
                  </entry>
                </xsl:if>
                <entry>
                  <xsl:if test="(normalize-space(@default) ne '') and not(xtlc:str2bln(@required, false()))">
                    <para>Default: <code><xsl:value-of select="@default"/></code></para>
                  </xsl:if>
                  <xsl:call-template name="output-docbook-contents">
                    <xsl:with-param name="encompassing-element" select="xdoc:description"/>
                  </xsl:call-template>
                  <xsl:call-template name="output-type-enums-table">
                    <xsl:with-param name="type" select="xdoc:type"/>
                  </xsl:call-template>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-type-info-in-description-table">
    <xsl:param name="type" as="element(xdoc:type)?" required="yes"/>
    <xsl:param name="column-width-cm" as="xs:double" required="yes"/>

    <xsl:for-each select="$type">
      <para>
        <code role="code-width-limited">
          <xsl:value-of select="(@base, @name)[1]"/>
        </code>
      </para>
      <xsl:call-template name="output-docbook-contents">
        <xsl:with-param name="encompassing-element" select="xdoc:description"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-type-enums-table">
    <xsl:param name="type" as="element(xdoc:type)?" required="yes"/>

    <xsl:for-each select="$type">
      <xsl:variable name="enums" as="element(xdoc:enum)*" select="xdoc:enum"/>
      <xsl:if test="exists($enums)">
        <xsl:variable name="enums-column-role" as="xs:string"
          select="'code-width-cm:' || $enums-table-value-column-min-width-cm || '-' || $enums-table-value-column-max-width-cm"/>
        <table role="nonumber">
          <title/>
          <tgroup cols="2">
            <colspec colname="value" role="{$enums-column-role}"/>
            <colspec colname="description"/>
            <thead>
              <row>
                <entry>Value</entry>
                <entry>Description</entry>
              </row>
            </thead>
            <tbody>
              <xsl:for-each select="$enums">
                <row>
                  <entry>
                    <code role="code-width-limited">
                      <xsl:value-of select="@value"/>
                    </code>
                  </entry>
                  <entry>
                    <xsl:call-template name="output-docbook-contents">
                      <xsl:with-param name="encompassing-element" select="xdoc:description"/>
                    </xsl:call-template>
                  </entry>
                </row>
              </xsl:for-each>
            </tbody>
          </tgroup>
        </table>
        <para role="smallbreak"/>
      </xsl:if>

    </xsl:for-each>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template name="output-docbook-contents">
    <!-- Will turn everything in the empty or in the xdoc namespace into the docbook namespace.
      Use either $elms or $encompassing-elements.-->
    <xsl:param name="elms" as="element()*" required="no" select="()"/>
    <xsl:param name="encompassing-element" as="element()?" required="no" select="()"/>

    <xsl:call-template name="convert-to-docbook-contents">
      <xsl:with-param name="elms" as="element()*" select="($elms, $encompassing-element/*)"/>
      <xsl:with-param name="convert-namespaces" as="xs:string*" select="($xdoc-namespace, '')"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:spaces" as="xs:string">
    <xsl:param name="length" as="xs:integer"/>
    <xsl:sequence select="xtlc:char-repeat(' ', $length)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:occurs-indicator" as="xs:string">
    <!-- This routine is here for future extension of the occurs mechanism. For now we only have 1, ?, +, * but maybe we need more 
      later (like specific numbers). -->
    <xsl:param name="element-with-occurs" as="element()"/>
    <xsl:variable name="occurs" as="xs:string" select="($element-with-occurs/@occurs, '1')[1]"/>
    <xsl:sequence select="if ($occurs eq '1') then '' else $occurs"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:mode name="mode-output-docbook-contents" on-no-match="shallow-copy"/>

  <xsl:template name="convert-to-docbook-contents">
    <!-- Will turn all elements in $elms in the $convert-namespaces namespaces into the docbook namespace -->
    <xsl:param name="elms" as="element()*" required="yes"/>
    <xsl:param name="convert-namespaces" as="xs:string*" required="yes"/>

    <xsl:apply-templates select="$elms" mode="mode-output-docbook-contents">
      <xsl:with-param name="convert-namespaces" as="xs:string*" select="$convert-namespaces" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" mode="mode-output-docbook-contents">
    <xsl:param name="convert-namespaces" as="xs:string*" required="yes" tunnel="true"/>
    <xsl:choose>
      <xsl:when test="string(namespace-uri(.)) = $convert-namespaces">
        <xsl:element name="{local-name(.)}" namespace="{$docbook-namespace}">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
