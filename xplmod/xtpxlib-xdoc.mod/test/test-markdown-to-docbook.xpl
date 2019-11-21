<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.h4c_m4g_2jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Test driver for the markdown-to-docbook library step. 
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:document href="test-markdown.xml"/>
  </p:input>

  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../xtpxlib-xdoc.mod.xpl"/>

  <!-- ================================================================== -->
 
  <xdoc:markdown-to-docbook/>
  
</p:declare-step>
