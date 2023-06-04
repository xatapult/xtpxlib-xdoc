<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all" type="xdoc:xdoc-to-pdf">

  <p:documentation>
     Convenience pipeline: Combines the [xdoc-to-docbook](%xdoc-to-docbook.xpl) and the [docbook-to-pdf](%docbook-to-pdf.xpl) steps in one.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The DocBook source with `xdoc` extensions</p:documentation>
  </p:input>

  <p:option name="href-parameters" required="false" select="()">
    <p:documentation>
      Optional reference to a document with parameter settings. 
      See [here](https://common.xtpxlib.org/1_Description.html#parameters-explanation) for details.
    </p:documentation>
  </p:option>

  <p:option name="parameter-filters" required="false" select="()">
    <p:documentation>Optional filter settings for processing the parameters. Format: `name=value|name=value|…`.</p:documentation>
  </p:option>

  <p:option name="href-pdf" required="true">
    <p:documentation>The name of the resulting PDF file</p:documentation>
  </p:option>

  <p:option name="preliminary-version" required="false" select="false()">
    <p:documentation>If `true`, adds a preliminary version marker and output any `db:remark` elements. 
        If `false`, output of `db:remark` elements will be suppressed.</p:documentation>
  </p:option>

  <p:option name="chapter-id" required="false" select="''">
    <p:documentation>Specific chapter identifier to output.</p:documentation>
  </p:option>

  <p:option name="fop-config" required="false"
    select="resolve-uri('../../xtpxlib-common/data/fop-default-config.xml', static-base-uri())">
    <p:documentation>Reference to the FOP configuration file</p:documentation>
  </p:option>

  <p:option name="output-type" required="false" select="'a4'">
    <p:documentation>Output type. Use either `a4` or `sb` (= standard book size)</p:documentation>
  </p:option>

  <p:option name="main-font-size" required="false" select="10">
    <p:documentation>Main font size as an integer. Usual values somewhere between 8 and 10.</p:documentation>
  </p:option>

  <p:option name="global-resources-directory" required="false" select="()">
    <p:documentation>Images that are tagged as `role="global"` are searched here (discarding any directory information in the image's URI)</p:documentation>
  </p:option>

  <p:option name="href-xsl-fo" required="false" select="()">
    <p:documentation>If set, writes the intermediate XSL-FO to this href (so you can inspect it when things go wrong in FOP)</p:documentation>
  </p:option>

  <p:option name="href-docbook" required="false" select="()">
    <p:documentation>If set, writes the intermediate full DocBook to this href (so you can inspect it when things go wrong)</p:documentation>
  </p:option>

  <p:option name="alttarget" required="false" select="()">
    <p:documentation>The target for applying alternate settings.</p:documentation>
  </p:option>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>Some XML report about the conversion</p:documentation>
  </p:output>

  <p:import href="xdoc-to-docbook.xpl"/>
  <p:import href="docbook-to-pdf.xpl"/>
  <p:import href="../../xtpxlib-common/xplmod/common.mod/common.mod.xpl"/>

  <!-- ================================================================== -->

  <xdoc:xdoc-to-docbook>
    <p:with-option name="href-parameters" select="$href-parameters"/>
    <p:with-option name="parameter-filters" select="$parameter-filters"/>
    <p:with-option name="alttarget" select="$alttarget"/>
  </xdoc:xdoc-to-docbook>

  <xtlc:tee>
    <p:with-option name="href" select="$href-docbook"/>
    <p:with-option name="enable" select="normalize-space($href-docbook) ne ''"/>
  </xtlc:tee>

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
