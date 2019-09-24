<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.szy_4kg_2jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <!-- ================================================================== -->

  <p:declare-step type="xdoc:markdown-to-docbook">

    <p:documentation>
      TBD
      Checks for elements xdoc:MARKDOWN. Replaces this with Docbook inside a xdoc:GROUP element.
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- SETUP: -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation> </p:documentation>
    </p:input>

    <p:option name="debug" required="false" select="false()"/>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation> </p:documentation>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:viewport match="xdoc:MARKDOWN">

      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xsl/convert-to-lines.xsl"/>
        </p:input>
        <p:with-param name="null" select="()"/>
      </p:xslt>

      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xsl/group-lines.xsl"/>
        </p:input>
        <p:with-param name="null" select="()"/>
      </p:xslt>
      
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xsl/process-inlines.xsl"/>
        </p:input>
        <p:with-param name="null" select="()"/>
      </p:xslt>
      
    </p:viewport>

  </p:declare-step>

  <!-- ================================================================== -->

</p:library>
