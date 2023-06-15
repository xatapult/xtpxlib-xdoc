<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns:local="#local.gqx_w5h_5xb" version="3.0" exclude-inline-prefixes="#all" name="this">

  <!-- ======================================================================= -->

  <p:import href="../code-docgen-dir.xpl"/>

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <xdoc:transform dir="../test-code-docgen" depth="0" id-suffix="SUFFIX-"/>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"/>

  <!-- ================================================================== -->

  <xdoc:code-docgen-dir/>

</p:declare-step>
