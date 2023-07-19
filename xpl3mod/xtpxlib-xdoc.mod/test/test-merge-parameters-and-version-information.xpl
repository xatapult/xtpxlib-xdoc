<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.h4c_m4g_2jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Test driver for the merge-parameters-and-version-information library step. 
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:inline>
      <dummy/>
    </p:inline>
  </p:input>

  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../xtpxlib-xdoc.mod.xpl"/>

  <!-- ================================================================== -->
 
  <xdoc:merge-parameters-and-version-information>
    <p:with-option name="href-parameters" select="resolve-uri('test-parameters-1.xml', static-base-uri())"/> 
    <p:with-option name="href-version-information" select="resolve-uri('../../../version.xml', static-base-uri())"/> 
    <p:with-option name="href-result" select="resolve-uri('../../../tmp/merge-parameters-and-version-information-result.xml', static-base-uri())"/> 
  </xdoc:merge-parameters-and-version-information>
  
</p:declare-step>
