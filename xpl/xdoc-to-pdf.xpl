<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
     Convenience pipeline: Combines the xdoc-to-docbook and the docbook-to-pdf steps in one.
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
  
  <p:option name="dref-pdf" required="true">
    <p:documentation>The name of the resulting PDF file</p:documentation>
  </p:option>
  
  <p:option name="preliminary-version" required="false" select="false()">
    <p:documentation>If true, adds a prelimiary version marker and output any db:remark elements. 
        If this is set to false, db:remark elements will be suppressed.</p:documentation>
  </p:option>
  
  <p:option name="chapter-id" required="false" select="''">
    <p:documentation>Specific chapter identifier to output (for debugging purposes)</p:documentation>
  </p:option>
  
  <p:option name="fop-config" required="false" select="resolve-uri('../../xtpxlib-common/data/fop-default-config.xml', static-base-uri())">
    <p:documentation>Reference to the FOP configuration file</p:documentation>
  </p:option>
  
  <p:option name="output-type" required="false" select="'a4'">
    <p:documentation>Output type. Use either a4 or sb (= standard book)</p:documentation>
  </p:option>
  
  <p:option name="main-font-size" required="false" select="10">
    <p:documentation>Main font size as an integer. Usual values somewhere between 8 and 10.</p:documentation>
  </p:option>
  
  <p:output port="result" primary="true" sequence="false">
    <p:documentation>Some XML report about the conversion</p:documentation>
  </p:output>

  <p:import href="xdoc-to-docbook.xpl"/>
  <p:import href="docbook-to-pdf.xpl"/>

  <!-- ================================================================== -->

  <xdoc:xdoc-to-docbook> 
    <p:with-option name="href-parameters" select="$href-parameters"/> 
    <p:with-option name="parameter-filters" select="$parameter-filters"/> 
  </xdoc:xdoc-to-docbook>

  <xdoc:docbook-to-pdf>
    <p:with-option name="dref-pdf" select="$dref-pdf"/> 
    <p:with-option name="preliminary-version" select="$preliminary-version"/> 
    <p:with-option name="chapter-id" select="$chapter-id"/> 
    <p:with-option name="fop-config" select="$fop-config"/> 
    <p:with-option name="output-type" select="$output-type"/> 
    <p:with-option name="main-font-size" select="$main-font-size"/> 
  </xdoc:docbook-to-pdf>

</p:declare-step>
