<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all" type="xdoc:xdoc-to-xhtml">

  <p:documentation>
     Convenience pipeline: Combines the [xdoc-to-docbook](%xdoc-to-docbook.xpl) and the [docbook-to-xhtml](%docbook-to-xhtml.xpl) steps in one.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The DocBook source with `xdoc` extensions</p:documentation>
  </p:input>
  
  <p:option name="href-parameters" required="false" select="()">
    <p:documentation>
      Optional reference to a document with parameter settings. 
      See [here](https://common.xtpxlib.org/1_Description.html#parameters-explanation) for details.
    </p:documentation>
  </p:option>
  
  <p:option name="parameter-filters" required="false" select="()">
    <p:documentation>Optional filter settings for processing the parameters. Format: `name=value|name=value|…`.</p:documentation>
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

  <xdoc:docbook-to-xhtml/>

</p:declare-step>
