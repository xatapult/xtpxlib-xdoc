<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.xyj_qhr_5xb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0" exclude-inline-prefixes="#all" name="docbook-to-pdf" type="xdoc:docbook-to-pdf">

  <p:documentation>
      This turns Docbook (5.1) into a PDF using FOP.
      
      All necessary `xdoc` pre-processing (usually with [xdoc-to-docbook.xpl](%xdoc-to-docbook.xpl)) must have been done.
      
      It will only convert a [partial DocBook tagset](%xdoc-docbook-dialect).
      
      If you don't use [xdoc-to-docbook.xpl](%xdoc-to-docbook.xpl), you have to make sure to get correct `xml:base` attributes in, so
      the pipeline can find includes and images. The following XProc (1.0) code takes care of that:

      ```
      <![CDATA[<p:xinclude>
        <p:with-option name="fixup-xml-base" select="true()"/> 
      </p:xinclude>
      <p:add-attribute attribute-name="xml:base" match="/*">
        <p:with-option name="attribute-value" select="/reference/to/source/document.xml"/>
      </p:add-attribute>]]>
      ```
      
    </p:documentation>

  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The Docbook source document, fully expanded (with appropriate `xml:base` attributes)</p:documentation>
    <p:document href="../test/pure-docbook-test.xml" use-when="$develop"/>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A small report thingie</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-pdf" as="xs:string" required="true" use-when="not($develop)">
    <p:documentation>The name of the resulting PDF file, as a URI (an absolute path must have `file://` in front).</p:documentation>
  </p:option>
  <p:option name="href-pdf" as="xs:string" required="false" select="resolve-uri('tmp/docbook-to-pdf-result.pdf', static-base-uri())"
    use-when="$develop"/>

  <p:option name="preliminary-version" as="xs:boolean" required="false" select="false()">
    <p:documentation>If `true`, adds a preliminary version marker and output any `db:remark` elements. 
        If `false`, output of `db:remark` elements will be suppressed.</p:documentation>
  </p:option>

  <p:option name="chapter-id" as="xs:string" required="false" select="''">
    <p:documentation>Specific chapter identifier to output.</p:documentation>
  </p:option>

  <p:option name="fop-config" as="xs:string" required="false"
    select="resolve-uri('../../xtpxlib-common/data/fop-default-config.xml', static-base-uri())">
    <p:documentation>Reference to the FOP configuration file</p:documentation>
  </p:option>

  <p:option name="output-type" as="xs:string" required="false" select="'a4'" values="('a4', 'sb')">
    <p:documentation>Output type. Use either `a4` or `sb` (= standard book size)</p:documentation>
  </p:option>

  <p:option name="main-font-size" as="xs:integer" required="false" select="10">
    <p:documentation>Main font size as an integer. Usual values somewhere between 8 and 10.</p:documentation>
  </p:option>

  <p:option name="global-resources-directory" as="xs:string?" required="false" select="()">
    <p:documentation>Images that are tagged as `role="global"` are searched here (discarding any directory information in the image's URI)</p:documentation>
  </p:option>

  <p:option name="href-xsl-fo" as="xs:string?" required="false" select="()" use-when="not($develop)">
    <p:documentation>If set, writes the intermediate XSL-FO to this href (so you can inspect it when things go wrong in FOP)</p:documentation>
  </p:option>
  <p:option name="href-xsl-fo" as="xs:string?" required="false" select="resolve-uri('tmp/docbook-to-pdf-xsl-fo.xml', static-base-uri())"
    use-when="$develop"/>

  <p:option name="create-pdf" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether to actually create the PDF.</p:documentation>
  </p:option>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Add identifiers and numbering: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-shared/add-identifiers.xsl"/>
  </p:xslt>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-shared/add-numbering.xsl"/>
  </p:xslt>

  <!-- Handle columns with code contents and code width limitations 
    (<colspec role="code-width-cm:1.2-4"/> and <code role="code-width-limited">) -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-docbook-to-pdf/handle-code-width-limited-columns.xsl"/>
    <p:with-option name="parameters" select="map{'main-font-size': $main-font-size}"/>
  </p:xslt>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-docbook-to-pdf/handle-code-width-limited-contents.xsl"/>
    <p:with-option name="parameters" select="map{'main-font-size': $main-font-size}"/>
  </p:xslt>

  <!-- Create the XSL-FO: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-docbook-to-pdf/db5-to-xsl-fo.xsl"/>
    <p:with-option name="parameters" select="map{
      'preliminary-version': $preliminary-version,
      'global-resources-directory': $global-resources-directory,
      'chapter-id': $chapter-id,
      'main-font-size': $main-font-size,
      'output-type': $output-type
    }"/>
  </p:xslt>
  <p:if test="normalize-space($href-xsl-fo) ne ''">
    <p:store href="{$href-xsl-fo}" serialization="map{'method': 'xml', 'indent': true()}"/>
  </p:if>

  <!-- Turn it into PDF: -->
  <p:if test="$create-pdf">
    <p:xsl-formatter>
      <p:with-option name="parameters" select="map{'user-config': xs:anyURI($fop-config)}"/>
    </p:xsl-formatter>
    <p:store href="{$href-pdf}"/>
  </p:if>

  <!-- Create some report thingie: -->
  <p:identity>
    <p:with-input>
      <docbook-to-pdf timestamp="{current-dateTime()}" create-pdf="{$create-pdf}" href-pdf="{$href-pdf}" href-xsl-fo="{$href-xsl-fo}"/>
    </p:with-input>
  </p:identity>

</p:declare-step>
