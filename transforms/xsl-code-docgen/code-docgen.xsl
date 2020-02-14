<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:local="#local-u67gh"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true" xmlns="http://docbook.org/ns/docbook">
  <!-- ================================================================== -->
  <!--~
    TBD
    
    TABLES ITH THE RIGHT CODING FOR THE FOP TABLE STUFF/COLWIDTH
    
    FILENAMES MUST BE UNIQUE
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>
  <xsl:include href="code-docgen-shared.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="local-namespace-prefixes" as="xs:string+" select="('local')">
    <!-- Anything in namespaces that uses one of these prefixes are considered local and ignored. -->
  </xsl:variable>

  <xsl:variable name="document-href" as="xs:string" select="xtlc:href-canonical((/xdoc:transform/*[1]/@xml:base, base-uri(/*))[1])"/>
  <xsl:variable name="document-filename" as="xs:string" select="xtlc:href-name($document-href)"/>

  <!-- Get some basic data. Make sure this also works when we *don't* have the XML to document wrapped inside an <xdoc:transform>: -->
  <xsl:variable name="document-root-element" as="element()" select="(/xdoc:transform/*, /*[1])[1]"/>
  <xsl:variable name="filecomponents" as="xs:integer" select="(xs:integer(/xdoc:transform/@filecomponents), 0)[1]"/>
  <xsl:variable name="header-level" as="xs:integer" select="(xs:integer(/xdoc:transform/@header-level), -1)[1]"/>
  <xsl:variable name="add-table-titles" as="xs:boolean" select="xtlc:str2bln(/xdoc:transform/@add-table-titles, false())"/>
  <xsl:variable name="sublevels" as="xs:boolean" select="xtlc:str2bln(/xdoc:transform/@sublevels, true())"/>

  <!-- Identifier information. The base id is either as @id on the xdoc:transform or is generated from the filename. -->
  <xsl:variable name="base-id" as="xs:string" select="xtlc:str2id((/xdoc:transform/@id, $document-filename)[1])"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <!-- First create a description in a <sect#> element: -->
    <xsl:variable name="description-section" as="element()">
      <xsl:element name="sect{$header-level}">
        <xsl:attribute name="xml:id" select="$base-id"/>
        <xsl:apply-templates select="$document-root-element"/>
      </xsl:element>
    </xsl:variable>
    <!-- Now output it: -->
    <xdoc:GROUP>
      <xsl:call-template name="output-section">
        <xsl:with-param name="title" as="node()+" select="$description-section/db:title/node()"/>
        <xsl:with-param name="contents" as="element()*" select="$description-section/* except $description-section/db:title"/>
        <xsl:with-param name="id" select="$description-section/@xml:id"/>
        <xsl:with-param name="force-bridgehead" select="false()"/>
      </xsl:call-template>
    </xdoc:GROUP>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SELECT ON TYPE OF DOCUMENT BY ROOT ELEMENT: -->

  <xsl:template match="xsl:stylesheet | xsl:transform">
    <xsl:call-template name="add-section-title-and-filename">
      <xsl:with-param name="base-title" select="'XSLT (' || @version || ')'"/>
    </xsl:call-template>

    <!-- Global information: -->
    <xsl:call-template name="get-element-documentation"/>
    <xsl:call-template name="output-important-namespaces">
      <xsl:with-param name="probable-names" select="xsl:*/@name/string()"/>
      <xsl:with-param name="title-part-1" select="'Namespaces used in global objects for'"/>
      <xsl:with-param name="title-part-2" select="$document-filename"/>
    </xsl:call-template>
    <xsl:call-template name="xsl-output-parameters">
      <xsl:with-param name="title-part-1" select="'Global parameters for'"/>
      <xsl:with-param name="title-part-2" select="$document-filename"/>
    </xsl:call-template>
    <xsl:call-template name="xsl-output-variables">
      <xsl:with-param name="title-part-1" select="'Global variables for'"/>
      <xsl:with-param name="title-part-2" select="$document-filename"/>
    </xsl:call-template>

    <!-- Gather information about relevant named templates and functions: -->
    <xsl:variable name="named-templates" as="element(xsl:template)*"
      select="$document-root-element/xsl:template[local:object-name-is-relevant(@name)]"/>
    <xsl:variable name="functions" as="element(xsl:function)*" select="$document-root-element/xsl:function[local:object-name-is-relevant(@name)]"/>

    <!-- Output overview tables for the named templates and functions: -->
    <xsl:call-template name="xsl-output-objects-overview">
      <xsl:with-param name="objects" select="$named-templates"/>
      <xsl:with-param name="object-type" select="'named template'"/>
    </xsl:call-template>
    <xsl:call-template name="xsl-output-objects-overview">
      <xsl:with-param name="objects" select="$functions"/>
      <xsl:with-param name="object-type" select="'function'"/>
    </xsl:call-template>

    <!-- Output the objects information: -->
    <xsl:call-template name="xsl-output-objects">
      <xsl:with-param name="objects" select="$named-templates"/>
      <xsl:with-param name="object-type" select="'named template'"/>
    </xsl:call-template>
    <xsl:call-template name="xsl-output-objects">
      <xsl:with-param name="objects" select="$functions"/>
      <xsl:with-param name="object-type" select="'function'"/>
    </xsl:call-template>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="p:declare-step">
    <xsl:variable name="object-name" as="xs:string" select="$document-filename"/>
    <xsl:call-template name="add-section-title-and-filename">
      <xsl:with-param name="base-title" select="'XProc (' || @version || ') pipeline'"/>
      <xsl:with-param name="object-name" select="$object-name"/>
    </xsl:call-template>
    <xsl:if test="exists(@type)">
      <para>Type: <code>{@type}</code></para>
    </xsl:if>
    <xsl:call-template name="xpl-get-element-documentation"/>
    <xsl:call-template name="output-important-namespaces">
      <xsl:with-param name="probable-names" select="p:option/@name/string()"/>
      <xsl:with-param name="title-part-1" select="'Global namespaces for'"/>
      <xsl:with-param name="title-part-2" select="$object-name"/>
    </xsl:call-template>
    <xsl:call-template name="xpl-output-ports">
      <xsl:with-param name="object-name" select="$object-name"/>
    </xsl:call-template>
    <xsl:call-template name="xpl-output-options">
      <xsl:with-param name="object-name" select="$object-name"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="p:library">
    <xsl:call-template name="add-section-title-and-filename">
      <xsl:with-param name="base-title" select="'XProc (' || @version || ') library'"/>
    </xsl:call-template>
    <xsl:call-template name="xpl-get-element-documentation"/>
    <xsl:call-template name="output-important-namespaces">
      <xsl:with-param name="probable-names"
        select="(p:declare-step[local:xpl-object-is-visible(.)]/@type/string(), p:option[local:xpl-object-is-visible(.)]/@name/string())"/>
      <xsl:with-param name="title-part-1" select="'Global namespaces for'"/>
      <xsl:with-param name="title-part-2" select="$document-filename"/>
    </xsl:call-template>
    <xsl:call-template name="xpl-output-options">
      <xsl:with-param name="main-title" select="'Global options for'"/>
      <xsl:with-param name="object-name" select="$document-filename"/>
    </xsl:call-template>

    <!-- Output steps: -->
    <xsl:variable name="step-declarations" as="element(p:declare-step)*"
      select="p:declare-step[local:xpl-object-is-visible(.)][local:object-name-is-relevant(@type)][exists(@type)]"/>
    <xsl:call-template name="xpl-output-steps-overview">
      <xsl:with-param name="step-declarations" select="$step-declarations"/>
    </xsl:call-template>
    <xsl:call-template name="xpl-output-steps">
      <xsl:with-param name="step-declarations" select="$step-declarations"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xs:schema">
    <xsl:call-template name="add-section-title-and-filename">
      <xsl:with-param name="base-title" select="'XML Schema'"/>
    </xsl:call-template>
    <xsl:if test="exists(@targetNamespace)">
      <para>Target namespace: <code>{ @targetNamespace }</code></para>
    </xsl:if>
    <xsl:call-template name="xsd-get-element-documentation"/>
    <xsl:call-template name="output-important-namespaces">
      <xsl:with-param name="probable-names" select="xs:element/@name/string()"/>
      <xsl:with-param name="title-part-1" select="'Global namespaces for'"/>
      <xsl:with-param name="title-part-2" select="$document-filename"/>
    </xsl:call-template>
    <xsl:call-template name="xsd-output-global-elements"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" priority="-1">
    <xsl:call-template name="add-section-title-and-filename">
      <xsl:with-param name="base-title" select="'XML document'"/>
    </xsl:call-template>
    <xsl:variable name="namespace-uri" as="xs:string" select="string(namespace-uri(.))"/>
    <para>
      <xsl:text>Root element: </xsl:text>
      <tag>{ name(.) }</tag>
      <xsl:if test="$namespace-uri ne ''">
        <xsl:text> (namespace: </xsl:text>
        <code>{ $namespace-uri }</code>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </para>
    <xsl:call-template name="get-element-documentation"/>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- XSL SUPPORT: -->

  <xsl:template name="xsl-output-parameters">
    <xsl:param name="parent-elm" as="element()" required="no" select="."/>
    <xsl:param name="title-part-1" as="xs:string" required="yes"/>
    <xsl:param name="title-part-2" as="xs:string?" required="no" select="()"/>

    <xsl:variable name="is-function" as="xs:boolean" select="exists($parent-elm/self::xsl:function)"/>
    <xsl:variable name="params" as="element(xsl:param)*" select="$parent-elm/xsl:param"/>
    <xsl:if test="exists($params)">
      <table>
        <xsl:call-template name="add-table-title">
          <xsl:with-param name="title-part-1" select="$title-part-1"/>
          <xsl:with-param name="title-part-2" select="$title-part-2"/>
        </xsl:call-template>
        <tgroup>
          <xsl:attribute name="cols" select="if ($is-function) then 3 else 5"/>
          <colspec role="code-width-cm:1.5-4"/>
          <colspec role="code-width-cm:1-4"/>
          <xsl:if test="not($is-function)">
            <colspec colwidth="0.7cm"/>
          </xsl:if>
          <xsl:if test="not($is-function)">
            <colspec role="code-width-cm:1-4"/>
          </xsl:if>
          <colspec/>
          <thead>
            <row>
              <entry>Parameter</entry>
              <entry>Type</entry>
              <xsl:if test="not($is-function)">
                <entry>Rq?</entry>
              </xsl:if>
              <xsl:if test="not($is-function)">
                <entry>Default</entry>
              </xsl:if>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$params">
              <!-- Do not sort function parameters, order is significant here! -->
              <xsl:sort select="if ($is-function) then () else @name"/>
              <row>
                <entry>
                  <para>
                    <code role="code-width-limited">{ @name }</code>
                  </para>
                </entry>
                <entry>
                  <para>
                    <code role="code-width-limited">{ @as }</code>
                  </para>
                </entry>
                <xsl:if test="not($is-function)">
                  <entry>
                    <para>
                      <xsl:call-template name="output-true-marker">
                        <xsl:with-param name="value" select="local:yes-no-to-boolean(@required, false())"/>
                      </xsl:call-template>
                    </para>
                  </entry>
                </xsl:if>
                <xsl:if test="not($is-function)">
                  <entry>
                    <para>
                      <code role="code-width-limited">{ @select }</code>
                    </para>
                  </entry>
                </xsl:if>
                <entry>
                  <xsl:call-template name="get-element-documentation"/>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xsl-output-variables">
    <xsl:param name="parent-elm" as="element()" required="no" select="."/>
    <xsl:param name="title-part-1" as="xs:string" required="yes"/>
    <xsl:param name="title-part-2" as="xs:string?" required="no" select="()"/>

    <xsl:variable name="variables" as="element(xsl:variable)*" select="$parent-elm/xsl:variable[local:object-name-is-relevant(@name)]"/>
    <xsl:if test="exists($variables)">
      <table>
        <xsl:call-template name="add-table-title">
          <xsl:with-param name="title-part-1" select="$title-part-1"/>
          <xsl:with-param name="title-part-2" select="$title-part-2"/>
        </xsl:call-template>
        <tgroup cols="4">
          <colspec role="code-width-cm:1.5-4"/>
          <colspec role="code-width-cm:1-4"/>
          <colspec role="code-width-cm:1-4"/>
          <colspec/>
          <thead>
            <row>
              <entry>Variable</entry>
              <entry>Type</entry>
              <entry>Value</entry>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$variables">
              <xsl:sort select="@name"/>
              <row>
                <entry>
                  <para>
                    <code role="code-width-limited">{ @name }</code>
                  </para>
                </entry>
                <entry>
                  <para>
                    <code role="code-width-limited">{ @as }</code>
                  </para>
                </entry>
                <entry>
                  <para>
                    <code role="code-width-limited">{ @select }</code>
                  </para>
                </entry>
                <entry>
                  <xsl:call-template name="get-element-documentation"/>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xsl-output-objects-overview">
    <!-- Outputs a table with overview information about named templates or functions -->
    <xsl:param name="objects" as="element()*" required="yes"/>
    <xsl:param name="object-type" as="xs:string" required="yes"/>

    <xsl:if test="exists($objects)">
      <table>
        <xsl:call-template name="add-table-title">
          <xsl:with-param name="title-part-1" select="'Global ' || $object-type || 's for'"/>
          <xsl:with-param name="title-part-2" select="$document-filename"/>
        </xsl:call-template>
        <tgroup cols="2">
          <colspec role="code-width-cm:1.5-4"/>
          <colspec/>
          <thead>
            <row>
              <entry>{ xtlc:capitalize($object-type) }</entry>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$objects">
              <xsl:sort select="@name"/>
              <row>
                <entry>
                  <para>
                    <code role="code-width-limited">
                      <link linkend="{local:xsl-object-id(.)}">{ local:xsl-object-name(.) }</link>
                    </code>
                  </para>
                </entry>
                <entry>
                  <xsl:call-template name="get-element-documentation">
                    <xsl:with-param name="header-only" select="true()"/>
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

  <xsl:template name="xsl-output-objects">
    <!-- Outputs objects (named templates or functions) information. -->
    <xsl:param name="objects" as="element()*" required="yes"/>
    <xsl:param name="object-type" as="xs:string" required="yes"/>

    <xsl:for-each select="$objects">
      <xsl:sort select="@name"/>
      <xsl:call-template name="output-section">
        <xsl:with-param name="id" select="local:xsl-object-id(.)"/>
        <xsl:with-param name="force-bridgehead" select="not($sublevels)"/>
        <xsl:with-param name="additional-level" select="true()"/>
        <xsl:with-param name="title" as="node()*">
          <xsl:value-of select="xtlc:capitalize($object-type)"/>
          <xsl:text>: </xsl:text>
          <code>
            <xsl:value-of select="local:xsl-object-name(.)"/>
            <xsl:if test="exists(@as)">
              <xsl:text> as </xsl:text>
              <xsl:value-of select="@as"/>
            </xsl:if>
          </code>
        </xsl:with-param>
        <xsl:with-param name="contents" as="element()*">
          <xsl:call-template name="get-element-documentation"/>
          <xsl:call-template name="xsl-output-parameters">
            <xsl:with-param name="title-part-1" select="'Parameters for'"/>
            <xsl:with-param name="title-part-2" select="local:xsl-object-name(.)"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:xsl-object-id" as="xs:string">
    <xsl:param name="object" as="element()"/>
    <xsl:sequence select="xtlc:str2id(string-join(($base-id, $object/@name, count($object/xsl:param)), '-'))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:xsl-object-name" as="xs:string">
    <xsl:param name="object" as="element()"/>
    <xsl:variable name="is-function" as="xs:boolean" select="exists($object/self::xsl:function)"/>
    <xsl:sequence select="$object/@name || (if ($is-function) then '()' else ())"/>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- XPROC SUPPORT: -->

  <xsl:template name="xpl-output-ports">
    <xsl:param name="parent-elm" as="element(p:declare-step)" required="no" select="."/>
    <xsl:param name="object-name" as="xs:string" required="yes"/>

    <xsl:variable name="pipeline-type" as="xs:string?" select="$parent-elm/@type"/>

    <!-- Ports: -->
    <xsl:variable name="port-declarations" as="element()*" select="$parent-elm/(p:input | p:output)"/>
    <xsl:if test="exists($port-declarations)">
      <table>
        <xsl:call-template name="add-table-title">
          <xsl:with-param name="title-part-1" select="'Ports for'"/>
          <xsl:with-param name="title-part-2" select="$object-name"/>
        </xsl:call-template>
        <tgroup cols="4">
          <colspec role="code-width-cm:1.5-4"/>
          <colspec colwidth="1cm"/>
          <colspec colwidth="1.5cm"/>
          <colspec/>
          <thead>
            <row>
              <entry>Port</entry>
              <entry>Type</entry>
              <entry>Primary?</entry>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$port-declarations">
              <!-- Sorting by local-name() makes input ports come first. -->
              <xsl:sort select="local-name()"/>
              <xsl:variable name="port-type" as="xs:string" select="local-name(.)"/>
              <xsl:variable name="is-only-definition-of-this-type" as="xs:boolean"
                select="empty(preceding-sibling::*[local-name() eq $port-type]) and empty(following-sibling::*[local-name() eq $port-type])"/>
              <xsl:variable name="is-primary" as="xs:boolean" select="xtlc:str2bln(@primary, false()) or $is-only-definition-of-this-type"/>
              <row>
                <entry>
                  <para>
                    <code role="code-width-limited">{ @port }</code>
                  </para>
                </entry>
                <entry>{ substring-before($port-type, 'put') }</entry>
                <entry>
                  <xsl:call-template name="output-true-marker">
                    <xsl:with-param name="value" select="$is-primary"/>
                  </xsl:call-template>
                </entry>
                <entry>
                  <xsl:call-template name="xpl-get-element-documentation"/>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xpl-output-options">
    <xsl:param name="parent-elm" as="element()" required="no" select="."/>
    <xsl:param name="main-title" as="xs:string" required="no" select="'Options for'"/>
    <xsl:param name="object-name" as="xs:string" required="yes"/>

    <!-- Options: -->
    <xsl:variable name="option-declarations" as="element(p:option)*" select="$parent-elm/p:option[local:xpl-object-is-visible(.)]"/>
    <xsl:variable name="has-type-info" as="xs:boolean" select="exists($option-declarations/@as)"/>
    <xsl:if test="exists($option-declarations)">
      <table>
        <xsl:call-template name="add-table-title">
          <xsl:with-param name="title-part-1" select="$main-title"/>
          <xsl:with-param name="title-part-2" select="$object-name"/>
        </xsl:call-template>
        <tgroup>
          <xsl:attribute name="cols" select="if ($has-type-info) then 5 else 4"/>
          <colspec role="code-width-cm:1.5-4"/>
          <xsl:if test="$has-type-info">
            <colspec role="code-width-cm:1-4"/>
          </xsl:if>
          <colspec colwidth="0.7cm"/>
          <colspec role="code-width-cm:1-4"/>
          <colspec/>
          <thead>
            <row>
              <entry>Option</entry>
              <xsl:if test="$has-type-info">
                <entry>Type</entry>
              </xsl:if>
              <entry>Rq?</entry>
              <entry>Default</entry>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$option-declarations">
              <xsl:sort select="@name"/>
              <row>
                <entry>
                  <para>
                    <code role="code-width-limited">{ @name }</code>
                  </para>
                </entry>
                <xsl:if test="$has-type-info">
                  <entry>
                    <para>
                      <code role="code-width-limited">{ @as }</code>
                    </para>
                  </entry>
                </xsl:if>
                <entry>
                  <para>
                    <xsl:call-template name="output-true-marker">
                      <xsl:with-param name="value" select="local:yes-no-to-boolean(@required, false())"/>
                    </xsl:call-template>
                  </para>
                </entry>
                <entry>
                  <para>
                    <code role="code-width-limited">{ @select }</code>
                  </para>
                </entry>
                <entry>
                  <xsl:call-template name="xpl-get-element-documentation"/>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xpl-output-steps-overview">
    <xsl:param name="step-declarations" as="element(p:declare-step)*" required="yes"/>

    <xsl:if test="count($step-declarations) gt 1">
      <table>
        <xsl:call-template name="add-table-title">
          <xsl:with-param name="title-part-1" select="'Global step declarations for'"/>
          <xsl:with-param name="title-part-2" select="$document-filename"/>
        </xsl:call-template>
        <tgroup cols="2">
          <colspec role="code-width-cm:1.5-4"/>
          <colspec/>
          <thead>
            <row>
              <entry>Step</entry>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$step-declarations">
              <xsl:sort select="@type"/>
              <row>
                <entry>
                  <para>
                    <code role="code-width-limited">
                      <link linkend="{local:xpl-object-id(.)}">{ @type }</link>
                    </code>
                  </para>
                </entry>
                <entry>
                  <xsl:call-template name="xpl-get-element-documentation">
                    <xsl:with-param name="header-only" select="true()"/>
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

  <xsl:template name="xpl-output-steps">
    <xsl:param name="step-declarations" as="element(p:declare-step)*" required="yes"/>

    <xsl:for-each select="$step-declarations">
      <xsl:sort select="@type"/>
      <xsl:call-template name="output-section">
        <xsl:with-param name="force-bridgehead" select="not($sublevels)"/>
        <xsl:with-param name="id" select="local:xpl-object-id(.)"/>
        <xsl:with-param name="additional-level" select="true()"/>
        <xsl:with-param name="title" as="node()+">
          <xsl:text>Step: </xsl:text>
          <code>{ @type }</code>
        </xsl:with-param>
        <xsl:with-param name="contents" as="element()*">
          <xsl:call-template name="xpl-get-element-documentation"/>
          <xsl:call-template name="xpl-output-ports">
            <xsl:with-param name="object-name" select="@type"/>
          </xsl:call-template>
          <xsl:call-template name="xpl-output-options">
            <xsl:with-param name="object-name" select="@type"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:xpl-object-is-visible" as="xs:boolean">
    <xsl:param name="object" as="element()"/>
    <xsl:sequence select="empty($object/@visibility) or ($object/@visibility ne 'private')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:xpl-object-id" as="xs:string">
    <xsl:param name="object" as="element(p:declare-step)"/>
    <xsl:sequence select="xtlc:str2id(string-join(($base-id, $object/@type), '-'))"/>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- XSD SUPPORT: -->

  <xsl:template name="xsd-output-global-elements">
    <xsl:param name="parent-elm" as="element(xs:schema)" required="no" select="."/>

    <xsl:variable name="global-elements" as="element(xs:element)*" select="$parent-elm/xs:element"/>
    <xsl:if test="exists($global-elements)">
      <table>
        <xsl:call-template name="add-table-title">
          <xsl:with-param name="title-part-1" select="'Global elements for'"/>
          <xsl:with-param name="title-part-2" select="$document-filename"/>
        </xsl:call-template>
        <tgroup cols="2">
          <colspec role="code-width-cm:1.5-4"/>
          <colspec/>
          <thead>
            <row>
              <entry>Element</entry>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$global-elements">
              <xsl:sort select="@name"/>
              <row>
                <entry>
                  <para>
                    <code role="code-width-limited">{ @name }</code>
                  </para>
                </entry>
                <entry>
                  <xsl:call-template name="xsd-get-element-documentation"/>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:if>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- GENERIC SUPPORT: -->

  <xsl:template name="output-important-namespaces">
    <!-- Gathers all the information about important namespaces. Namespaces are important when they are used in templates, functions and names
      of other globally visible objects (like variables, attribute-sets, etc.). You pass the names of these objects in $probable-names.
      The namespace prefixes in $local-namespace-prefixes are considered local and not processed.
      When found, creates a table with information. 
      All important namespace prefixes *must* be defined on the root element!
    -->
    <xsl:param name="probable-names" as="xs:string*" required="yes"/>
    <xsl:param name="title-part-1" as="xs:string" required="yes"/>
    <xsl:param name="title-part-2" as="xs:string?" required="no" select="()"/>

    <!-- Gather all the applicable namespace prefixes: -->
    <xsl:variable name="important-namespace-prefixes" as="xs:string*"
      select="distinct-values(for $name in $probable-names[local:object-name-is-relevant(.)] return substring-before($name, ':'))"/>

    <!-- Process these into a <namespaces> structure: -->
    <xsl:if test="exists($important-namespace-prefixes)">
      <table>
        <xsl:call-template name="add-table-title">
          <xsl:with-param name="title-part-1" select="$title-part-1"/>
          <xsl:with-param name="title-part-2" select="$title-part-2"/>
        </xsl:call-template>
        <tgroup cols="2">
          <colspec role="code-width-cm:2-4"/>
          <colspec/>
          <thead>
            <row>
              <entry>Prefix</entry>
              <entry>Namespace URI</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="$important-namespace-prefixes">
              <xsl:sort select="."/>
              <xsl:variable name="prefix" as="xs:string" select="."/>
              <xsl:variable name="namespace-uri" as="xs:string"
                select="string((namespace-uri-for-prefix($prefix, $document-root-element), '#not-defined-on-root')[1])"/>
              <row>
                <entry>
                  <para>
                    <code role="code-width-limited">{ $prefix }</code>
                  </para>
                </entry>
                <entry>
                  <para>
                    <code>{ $namespace-uri }</code>
                  </para>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:object-name-is-relevant" as="xs:boolean">
    <xsl:param name="name" as="xs:string?"/>

    <xsl:choose>
      <xsl:when test="empty($name)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <!-- Names in no namespace are considered local and therefore not relevant: -->
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

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:yes-no-to-boolean" as="xs:boolean">
    <xsl:param name="yes-no" as="xs:string?"/>
    <xsl:param name="default" as="xs:boolean"/>
    <xsl:choose>
      <xsl:when test="empty($yes-no)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="$yes-no castable as xs:boolean">
        <xsl:sequence select="xs:boolean($yes-no)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$yes-no eq 'yes'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-table-title">
    <xsl:param name="title-part-1" as="xs:string" required="yes"/>
    <xsl:param name="title-part-2" as="xs:string?" required="no" select="()"/>

    <xsl:if test="not($add-table-titles)">
      <xsl:attribute name="role" select="'nonumber'"/>
    </xsl:if>
    <title>
      <xsl:if test="$add-table-titles">
        <xsl:value-of select="$title-part-1"/>
        <xsl:if test="exists($title-part-2)">
          <xsl:text> </xsl:text>
          <code>{ $title-part-2 }</code>
        </xsl:if>
      </xsl:if>
    </title>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-section-title-and-filename">
    <!-- Outputs the title of a section and adds the first line that contains the filename information (based on the $filecomponents setting) -->
    <xsl:param name="base-title" as="xs:string" required="yes"/>
    <xsl:param name="object-name" as="xs:string" required="no" select="$document-filename"/>

    <!-- Section title: -->
    <title>
      <xsl:text>{ $base-title }</xsl:text>
      <xsl:text>: </xsl:text>
      <code>{ $object-name }</code>
    </title>

    <!-- Filename paragraph: -->
    <xsl:variable name="href-normalized" as="xs:string" select="xtlc:href-protocol-remove(xtlc:href-canonical($document-href))"/>
    <xsl:variable name="filename-for-display" as="xs:string?">
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
    <xsl:if test="exists($filename-for-display)">
      <para role="keep-with-next">File: <code>{ $filename-for-display }</code></para>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-true-marker">
    <xsl:param name="value" as="xs:boolean" required="yes"/>

    <xsl:choose>
      <xsl:when test="$value">
        <xsl:text>yes</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-section">
    <xsl:param name="title" as="node()+" required="yes"/>
    <xsl:param name="contents" as="element()+" required="yes"/>
    <xsl:param name="id" as="xs:string?" required="false" select="()"/>
    <xsl:param name="additional-level" as="xs:boolean" required="false" select="false()"/>
    <xsl:param name="force-bridgehead" as="xs:boolean" required="false" select="false()"/>

    <xsl:choose>
      <xsl:when test="$force-bridgehead or ($header-level le 0)">
        <bridgehead>
          <xsl:if test="exists($id)">
            <xsl:attribute name="xml:id" select="$id"/>
          </xsl:if>
          <xsl:copy-of select="$title" copy-namespaces="false"/>
        </bridgehead>
        <xsl:copy-of select="$contents" copy-namespaces="false"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="level" as="xs:integer" select="if ($additional-level) then ($header-level + 1) else $header-level"/>
        <xsl:element name="sect{$level}">
          <xsl:if test="exists($id)">
            <xsl:attribute name="xml:id" select="$id"/>
          </xsl:if>
          <title>
            <xsl:copy-of select="$title" copy-namespaces="false"/>
          </title>
          <xsl:copy-of select="$contents" copy-namespaces="false"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xdoc:warning-prevention-template"/>

</xsl:stylesheet>
