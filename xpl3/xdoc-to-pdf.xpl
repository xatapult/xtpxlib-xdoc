<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.z4q_vrr_5xb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0" exclude-inline-prefixes="#all" name="xdoc-to-pdf" type="xdoc:xdoc-to-pdf">

  <p:documentation>
     Convenience pipeline: Combines the [xdoc-to-docbook](%xdoc-to-docbook.xpl) and the [docbook-to-pdf](%docbook-to-pdf.xpl) steps in one.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="xdoc-to-docbook.xpl"/>
  <p:import href="docbook-to-pdf.xpl"/>

  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The Docbook source, with option al `xdoc` extensions.</p:documentation>
    <p:document href="{resolve-uri('../test/xdoc-docbook-test-3.xml', static-base-uri())}" use-when="$develop"/>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A small report thingie</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-parameters" as="xs:string?" required="false" select="()" use-when="not($develop)">
    <p:documentation>
      Optional reference to a document with parameter settings. 
      See [here](https://common.xtpxlib.org/1_Description.html#parameters-explanation) for details.
    </p:documentation>
  </p:option>
  <p:option name="href-parameters" as="xs:string?" required="false" select="resolve-uri('../test/parameters.xml', static-base-uri())"
    use-when="$develop"/>

  <p:option name="parameter-filters-map" as="map(xs:string, xs:string)" required="false" select="map{}" use-when="not($develop)">
    <p:documentation>Optional filter settings for processing the parameters.</p:documentation>
  </p:option>
  <p:option name="parameter-filters-map" as="map(xs:string, xs:string)" required="false" select="map{}" use-when="$develop"/>

  <p:option name="alttarget" as="xs:string?" required="false" select="()">
    <p:documentation>The target for applying alternate settings.</p:documentation>
  </p:option>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

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

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <p:option name="href-docbook" as="xs:string?" required="false" select="()">
    <p:documentation>If set, writes the intermediate full DocBook to this href (so you can inspect it when things go wrong)</p:documentation>
  </p:option>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <xdoc:xdoc-to-docbook>
    <p:with-option name="href-parameters" select="$href-parameters"/>
    <p:with-option name="parameter-filters-map" select="$parameter-filters-map"/>
    <p:with-option name="alttarget" select="$alttarget"/>
  </xdoc:xdoc-to-docbook>

  <p:if test="normalize-space($href-docbook) ne ''">
    <p:store href="{$href-docbook}" serialization="map{'method': 'xml', 'indent': true()}"/>
  </p:if>

  <xdoc:docbook-to-pdf>
    <p:with-option name="href-pdf" select="$href-pdf"/>
    <p:with-option name="preliminary-version" select="$preliminary-version"/>
    <p:with-option name="chapter-id" select="$chapter-id"/>
    <p:with-option name="fop-config" select="$fop-config"/>
    <p:with-option name="output-type" select="$output-type"/>
    <p:with-option name="main-font-size" select="$main-font-size"/>
    <p:with-option name="global-resources-directory" select="$global-resources-directory"/>
    <p:with-option name="href-xsl-fo" select="$href-xsl-fo"/>
  </xdoc:docbook-to-pdf>

</p:declare-step>
