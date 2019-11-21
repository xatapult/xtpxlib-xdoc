<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all" >

  <p:documentation>
      This pipeline takes some document (XSL, XSD, ordinary XML, etc.), wrapped inside an `xdoc:transform` element, and searches it for documentation. 
      It then tries to auto-generate documentation in the intermediate docgen format (see `xsd/docgen-intermediate.xsd`).
      
      When the format has the means to add documentation of itself (like for XProc and XML Schema), this is used.
      When there is no such thing (like for XSLT and straight XML), comments starting with a tilde (`~`) are used. 
      
      The descriptions can contain simple Markdown.
      
      You can use an `@filecomponents` attribute on the `xdoc:transform` element to control the way the filename is displayed:
      - When lt 0, no filename is displayed
      - When eq 0, the full filename (with full path) is displayed
      - When gt 0, this number of filename components is displayed. So 1 means filename only, 2 means filename and direct foldername, etc.
      
      TBD: @header-level
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The document to generate documentation for, wrapped in an xdoc:transform element. TBD also works without wrapper</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting docbook 5 output</p:documentation>
  </p:output>
  <p:serialization port="result" indent="true" method="xml"/>
  
  <p:import href="../../xplmod/xtpxlib-xdoc.mod/xtpxlib-xdoc.mod.xpl"/>

  <!-- ================================================================== -->

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl/code-docgen.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>
  
  <!-- Resolve any Markdown stuff: -->
  <xdoc:markdown-to-docbook/>
  
</p:declare-step>
