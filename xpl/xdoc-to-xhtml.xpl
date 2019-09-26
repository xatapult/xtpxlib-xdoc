<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
     Convenience pipeline: Combines the xdoc-to-docbook and the docbook-to-xhtml steps in one.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The DocBook source with xdoc extensions</p:documentation>
  </p:input>
  
  <p:option name="href-parameters" required="false" select="()">
    <p:documentation>Reference to an optional document with parameter settings. See the xtpxlib-common parameters.mod.xsl module for details.</p:documentation>
  </p:option>
  
  <p:option name="parameter-filters" required="false" select="()">
    <p:documentation>Filter settings for processing the parameters. Format: "name=value|name=value|..."</p:documentation>
  </p:option>
  
  <p:option name="create-header" required="false" select="true()">
    <p:documentation>Whether to create header (title, etc.) information</p:documentation>
  </p:option>
  
  <p:option name="base-href" required="false" select="''">
    <p:documentation>Base href for resolving image references</p:documentation>
  </p:option>
  
  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting XHTML</p:documentation>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="xdoc-to-docbook.xpl"/>
  <p:import href="docbook-to-xhtml.xpl"/>

  <!-- ================================================================== -->

  <xdoc:xdoc-to-docbook> 
    <p:with-option name="href-parameters" select="$href-parameters"/> 
    <p:with-option name="parameter-filters" select="$parameter-filters"/> 
  </xdoc:xdoc-to-docbook>

  <xdoc:docbook-to-xhtml>
    <p:with-option name="create-header" select="$create-header"/> 
    <p:with-option name="base-href" select="$base-href"/> 
  </xdoc:docbook-to-xhtml>

</p:declare-step>
