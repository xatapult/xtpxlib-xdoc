<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
      Turns an XML element description into the appropriate Docbook.
    </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The document containing the XML description, wrapped in an xdoc:transform element.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting docbook 5 output</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xml-description/do-element-description.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>

</p:declare-step>
