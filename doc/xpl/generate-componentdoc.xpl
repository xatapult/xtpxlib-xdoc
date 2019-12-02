<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all">

  <p:documentation>
    TBD
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>TBD</p:documentation>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../../../xtpxlib-webdoc/xpl/xdoc-to-componentdoc-website.xpl"/>

  <!-- ================================================================== -->

  <p:variable name="href-parameters" select="resolve-uri('../data/xtpxlib-xdoc-componentdoc-parameters.xml', static-base-uri())"/>
  <p:variable name="href-global-parameters"
    select="resolve-uri('../../../xtpxlib-webdoc/doc/data/componentdoc-global-parameters.xml', static-base-uri())"/>
  <p:variable name="global-resources-dir" select="resolve-uri('../../../xtpxlib-webdoc/doc/global-resources/', static-base-uri())"/>
  <p:variable name="href-template" select="resolve-uri('../../../xtpxlib-webdoc/doc/data/componentdoc-website-template.html', static-base-uri())"/>
  <p:variable name="output-directory" select="resolve-uri('../../docs/', static-base-uri())"/>

  <xwebdoc:xdoc-to-componentdoc-website>
    <p:input port="source">
      <p:document href="../source/xtpxlib-xdoc-componentdoc.xml"/>
    </p:input>
    <p:with-option name="component-name" select="'xtpxlib-xdoc'"/>
    <p:with-option name="href-parameters" select="$href-parameters"/>
    <p:with-option name="parameter-filters" select="()"/>
    <p:with-option name="href-global-parameters" select="$href-global-parameters"/>
    <p:with-option name="resources-subdirectory" select="'resources/'"/>
    <p:with-option name="global-resources-directory" select="$global-resources-dir"/>
    <p:with-option name="href-template" select="$href-template"/>
    <p:with-option name="output-directory" select="$output-directory"/>
  </xwebdoc:xdoc-to-componentdoc-website>

</p:declare-step>
