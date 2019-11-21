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

    <p:option name="debug" required="false" select="false()"/>

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

  <!-- ================================================================== -->

  <p:declare-step type="xdoc:merge-parameters-and-version-information" name="merge-parameters-and-version-information">

    <p:documentation>
      Merges a set of parameters with information from a standard xtpxlib component version information file. Writes this file to disk.
      Acts like a p:identity step, primary input is passed unchanged to the primary output.
      
      Turns the version information into the following parameters:
      * `component-name`
      * `git-uri`
      * `github-pages-uri` (optional)
      * `current-release-version`
      * `current-release-date`
      * `component-dependencies`
    </p:documentation>

    <p:option name="href-parameters" required="false" select="()">
      <p:documentation>Reference to an optional document with parameter settings. See the xtpxlib-common parameters.mod.xsl module for details.</p:documentation>
    </p:option>

    <p:option name="href-global-parameters" required="false" select="()">
      <p:documentation>Optional global parameters file. The parameters from this file will be merged in as well.</p:documentation>
    </p:option>

    <p:option name="href-version-information" required="false" select="()">
      <p:documentation>Reference to an optional standard xtpxlib version in formation document.</p:documentation>
    </p:option>

    <p:option name="href-result" required="true">
      <p:documentation>Location where to write the result. Always emits a valid parameters document.</p:documentation>
    </p:option>

    <p:input port="source" primary="true" sequence="true">
      <p:documentation>Input and output port of this step simply pass anything through, like a `p:identity` step</p:documentation>
    </p:input>
    <p:output port="result" primary="true" sequence="true">
      <p:documentation>Input and output port of this step simply pass anything through, like a `p:identity` step</p:documentation>
      <p:pipe port="source" step="merge-parameters-and-version-information"/>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:xslt>
      <p:input port="source">
        <p:inline>
          <null/>
        </p:inline>
      </p:input>
      <p:input port="stylesheet">
        <p:document href="xsl-merge-parameters-and-version-information/merge-parameters-and-version-information.xsl"/>
      </p:input>
      <p:with-param name="href-parameters" select="$href-parameters"/>
      <p:with-param name="href-global-parameters" select="$href-global-parameters"/>
      <p:with-param name="href-version-information" select="$href-version-information"/>
    </p:xslt>
    <p:store method="xml" indent="true" encoding="UTF-8" omit-xml-declaration="false">
      <p:with-option name="href" select="$href-result"/>
    </p:store>

  </p:declare-step>

</p:library>
