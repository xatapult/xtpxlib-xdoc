<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
     TBD
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:document href="pure-docbook-test.xml"/>
  </p:input>
  
  <p:option name="href-pdf" required="false" select="resolve-uri('../tmp/test-fo-from-pure-docbook.pdf', static-base-uri())"/>
  
  <p:option name="href-xsl-fo" required="false" select="resolve-uri('../tmp/test-fo-xsl-fo.xml', static-base-uri())"></p:option>
  
  <p:output port="result" primary="true" sequence="false"/>

  <p:import href="../xpl/docbook-to-pdf.xpl"/>

  <!-- ================================================================== -->

  <xdoc:docbook-to-pdf>
    <p:with-option name="href-pdf" select="$href-pdf"/> 
    <p:with-option name="href-xsl-fo" select="$href-xsl-fo"></p:with-option>
  </xdoc:docbook-to-pdf>

</p:declare-step>
