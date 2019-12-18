<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
     TBD
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:document href="xdoc-docbook-test.xml"/>
  </p:input>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Parameters for xdoc-to-docbook: -->

  <p:option name="href-parameters" required="false" select="resolve-uri('parameters.xml', static-base-uri())"/>

  <p:option name="parameter-filters" required="false" select="'system=prd'"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Parameters for docbook-to-pdf -->

  <p:option name="href-pdf" required="false" select="resolve-uri('../tmp/test-xdoc-to-pdf.pdf', static-base-uri())"/>

  <p:option name="preliminary-version" required="false" select="true()"/>

  <p:option name="chapter-id" required="false" select="''"/>

  <p:option name="fop-config" required="false" select="resolve-uri('../../xtpxlib-common/data/fop-default-config.xml', static-base-uri())"/>

  <p:option name="output-type" required="false" select="'a4'"/>
  <!-- Use either a4 or sb (= standard book) -->

  <p:option name="main-font-size" required="false" select="10"/>
  <!-- Usually between 8 and 10 -->
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <p:output port="result" primary="true" sequence="false"/>

  <p:import href="../xpl/xdoc-to-docbook.xpl"/>
  <p:import href="../xpl/docbook-to-pdf.xpl"/>

  <!-- ================================================================== -->

  <xdoc:xdoc-to-docbook> 
    <p:with-option name="href-parameters" select="$href-parameters"/> 
    <p:with-option name="parameter-filters" select="$parameter-filters"/> 
  </xdoc:xdoc-to-docbook>

  <xdoc:docbook-to-pdf>
    <p:with-option name="href-pdf" select="$href-pdf"/> 
    <p:with-option name="preliminary-version" select="$preliminary-version"/> 
    <p:with-option name="chapter-id" select="$chapter-id"/> 
    <p:with-option name="fop-config" select="$fop-config"/> 
    <p:with-option name="output-type" select="$output-type"/> 
    <p:with-option name="main-font-size" select="$main-font-size"/> 
  </xdoc:docbook-to-pdf>

</p:declare-step>
