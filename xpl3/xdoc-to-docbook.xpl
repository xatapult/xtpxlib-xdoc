<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.blk_hqb_5xb" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0"
  exclude-inline-prefixes="#all" type="xdoc:xdoc-to-docbook"  name="xdoc-to-docbook">

  <p:documentation>
    XProc 3.0 pipeline that transforms a DocBook source containing `xdoc` extensions into "pure" DocBook format.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

<!-- TBD -->

  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:document href="{resolve-uri('../test/xdoc-docbook-test.xml', static-base-uri())}" use-when="$develop"/>
    <p:documentation>The DocBook source with `xdoc` extensions</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The resulting DocBook.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-parameters" as="xs:string?" required="false" select="()" use-when="not($develop)">
    <p:documentation>
      Optional reference to a document with parameter settings. 
      See [here](https://common.xtpxlib.org/1_Description.html#parameters-explanation) for details.
    </p:documentation>
  </p:option>
  <p:option name="href-parameters" as="xs:string?" required="false" select="resolve-uri('../test/parameters.xml', static-base-uri())" use-when="$develop"/>
  
  <p:option name="parameter-filters-map" as="map(xs:string, xs:string)" required="false" select="map{}" use-when="not($develop)">
    <p:documentation>Optional filter settings for processing the parameters.</p:documentation>
  </p:option>
  <p:option name="parameter-filters-map" as="map(xs:string, xs:string)" required="false" select="map{}" use-when="$develop"/>
    
  <p:option name="alttarget" as="xs:string?" required="false" select="()">
    <p:documentation>The target for applying alternate settings.</p:documentation>
  </p:option>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Process the XIncludes. But before that, check for parameter references in the 
    xi:include/@href attributes first. -->
  <!--<p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-docbook/substitute-parameters-xinclude-href.xsl"/>
    <p:with-option name="parameters" select="map{'href-parameters': $href-parameters, 'parameter-filters-map': $parameter-filters-map}"/>
  </p:xslt>-->
  <p:xinclude fixup-xml-base="true"/>

</p:declare-step>
