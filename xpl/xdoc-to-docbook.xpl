<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.pfs_dr3_h3b" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="1.0"
  xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Pipeline that transforms a DocBook source containing xdoc extensions into true DocBook format.
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
    <p:documentation>Filter settings for processing the parameters. Format: "name|value|name|value|..."</p:documentation>
  </p:option>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting true DocBook</p:documentation>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <!-- ================================================================== -->

  <!-- Process any <xdoc:dump-parameters>: -->
  <p:viewport match="xdoc:dump-parameters">
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/dump-parameters.xsl"/>
      </p:input>
      <p:with-param name="href-parameters" select="$href-parameters"/>
      <p:with-param name="parameter-filters" select="$parameter-filters"/>
    </p:xslt>
  </p:viewport>
  
  <!-- Now process the XIncludes. But before that, check for parameter references in the xi:include/@href attributes first. -->
  <!-- TBD REMARK: Xinclude already seems to happen way before we do this... Question is out! -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl/substitute-parameters-xinclude-href.xsl"/>
    </p:input>
    <p:with-param name="href-parameters" select="$href-parameters"/>
    <p:with-param name="parameter-filters" select="$parameter-filters"/>
  </p:xslt>
  <p:xinclude>
    <p:with-option name="fixup-xml-base" select="true()"/>
  </p:xinclude>  
  
  <!-- Substitute all parameter references: -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl/substitute-parameters.xsl"/>
    </p:input>
    <p:with-param name="href-parameters" select="$href-parameters"/>
    <p:with-param name="parameter-filters" select="$parameter-filters"/>
  </p:xslt>
  
</p:declare-step>
