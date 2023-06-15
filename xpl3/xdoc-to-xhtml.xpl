<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.z4q_vrr_5xb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0" exclude-inline-prefixes="#all" name="xdoc-to-pdf" type="xdoc:xdoc-to-pdf">

  <p:documentation>
     Convenience pipeline: Combines the [xdoc-to-docbook](%xdoc-to-docbook.xpl) and the [docbook-to-xhtml](%docbook-to-xhtml.xpl) steps in one.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="xdoc-to-docbook.xpl"/>
  <p:import href="docbook-to-xhtml.xpl"/>

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
    <p:documentation>The resulting XHTML.</p:documentation>
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

  <xdoc:docbook-to-xhtml/>

</p:declare-step>
