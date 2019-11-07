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
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The document to generate documentation for, wrapped in an xdoc:transform element.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting docbook 5 output</p:documentation>
  </p:output>
  
  <p:import href="../../xplmod/markdown-to-docbook/markdown-to-docbook.mod.xpl"/>

  <!-- ================================================================== -->

  <!-- Turn the thing to document into intermediate format: -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl/document-to-docgen-intermediate.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>
  <p:identity name="docgen-intermediate"/>
  
  <!-- Validate this (comment-out when not developing): -->
  <!--<p:validate-with-xml-schema>
    <p:input port="schema">
      <p:document href="xsd/docgen-intermediate.xsd"/>
    </p:input>
  </p:validate-with-xml-schema>
  <p:sink/>-->
  
  <!-- Make it into DocBook: -->
  <p:xslt>
    <!-- Remark: We read the input from before the intermediate format was validated. Otherwise we get a PSVI annotated version 
      of it which breaks the XSLT... -->
    <p:input port="source">
      <p:pipe port="result" step="docgen-intermediate"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="xsl/docgen-intermediate-to-docbook.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>
  
  <!-- Resolve any Markdown stuff: -->
  <xdoc:markdown-to-docbook/>
  
</p:declare-step>
