<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.xbs_1rr_5xb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0" exclude-inline-prefixes="#all" name="docbook-to-xhtml" type="xdoc:docbook-to-xhtml">

  <p:documentation>
      This turns Docbook (5.1) into XHTML.
      
      All necessary `xdoc` pre-processing (usually with [xdoc-to-docbook.xpl](%xdoc-to-docbook.xpl)) must have been done.
      
      It will only convert a [partial DocBook tagset](%xdoc-docbook-dialect).
      
      The resulting XHTML will not be directly useable, post-processing the result into a complete and correct HTML page is necessary. 
      The result of this pipeline consists of nested `div` elements. There is no surrounding `html` or `body` element.
    </p:documentation>

  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The docbook source document.</p:documentation>
    <p:document href="../test/pure-docbook-test.xml" use-when="$develop"/>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The resulting XHTML</p:documentation>
  </p:output>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Add identifiers and numbering: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-shared/add-identifiers.xsl"/>
  </p:xslt>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-shared/add-numbering.xsl"/>
  </p:xslt>

  <!-- Turn it into XHTML: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-docbook-to-xhtml/db5-to-xhtml.xsl"/>
  </p:xslt>

</p:declare-step>
