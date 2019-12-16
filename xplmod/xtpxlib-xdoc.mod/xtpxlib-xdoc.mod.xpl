<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.szy_4kg_2jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:db="http://docbook.org/ns/docbook" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    TBD Generic library
  </p:documentation>

  <!-- ================================================================== -->

  <p:declare-step type="xdoc:markdown-to-docbook">

    <p:documentation>
      Checks for elements xdoc:MARKDOWN. Replaces these with Docbook contents.
      
      Only simple Markdown is supported (e.g. no tables).
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- SETUP: -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation> </p:documentation>
    </p:input>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation> </p:documentation>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:viewport match="xdoc:MARKDOWN">

      <!-- Turn everything into lines: -->
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xsl-markdown-to-docbook/convert-to-lines.xsl"/>
        </p:input>
        <p:with-param name="null" select="()"/>
      </p:xslt>

      <!-- Group lines into paragraphs: -->
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xsl-markdown-to-docbook/group-lines.xsl"/>
        </p:input>
        <p:with-param name="null" select="()"/>
      </p:xslt>

      <!-- Handle inline markup (like `code`, *italic*, etc.): -->
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xsl-markdown-to-docbook/process-inlines.xsl"/>
        </p:input>
        <p:with-param name="null" select="()"/>
      </p:xslt>

      <!-- List handling: -->
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xsl-markdown-to-docbook/handle-lists.xsl"/>
        </p:input>
        <p:with-param name="null" select="()"/>
      </p:xslt>
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xsl-markdown-to-docbook/handle-lists-finalize.xsl"/>
        </p:input>
        <p:with-param name="null" select="()"/>
      </p:xslt>

    </p:viewport>

    <!-- Remove the trigger element: -->
    <p:unwrap match="xdoc:MARKDOWN"/>

  </p:declare-step>

</p:library>
