<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all" type="xdoc:docbook-to-xhtml">

  <p:documentation>
      This turns Docbook (5.1) into XHTML.
      
      All necessary `xdoc` pre-processing (usually with [xdoc-to-docbook.xpl](%xdoc-to-docbook.xpl)) must have been done.
      
      It will only convert a [partial DocBook tagset](%xdoc-docbook-dialect).
      
      The resulting XHTML will not be directly useable, post-processing the result into a complete and correct HTML page is necessary. 
      The result of this pipeline consists of nested `div` elements. There is no surrounding `html` or `body` element.
    </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The docbook source document.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting XHTML</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-shared/add-identifiers.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>
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
    <p:with-param name="null" select="()"/>
  </p:xslt>

</p:declare-step>
