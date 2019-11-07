<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all" type="xdoc:docbook-to-xhtml">

  <p:documentation>
      This turns Docbook (5.1) into XHTML.
      
      All necessary pre-processing (resolving xincludes, expanding variables, examples, etc.) must have been done before this.
      To make sure we can find the images and other stuff, add appropriate xml:base attributes.
      
      It will only convert a partial DocBook tagset. See TBD.
      
    </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The docbook source document, fully expanded (with appropriate xml:base attributes)</p:documentation>
  </p:input>

  <p:option name="create-header" required="false" select="true()">
    <p:documentation>Whether to create header (title, etc.) information</p:documentation>
  </p:option>

  <p:option name="base-href" required="false" select="''">
    <p:documentation>Base href for resolving image references</p:documentation>
  </p:option>
  
  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting XHTML</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-shared/add-numbering.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>
  
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-docbook-to-xhtml/db5-to-xhtml.xsl"/>
    </p:input>
    <p:with-param name="create-header" select="$create-header"/>
    <p:with-param name="base-href" select="$base-href"/>
  </p:xslt>

</p:declare-step>
