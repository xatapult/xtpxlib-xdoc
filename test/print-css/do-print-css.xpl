<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.xwv_tzj_vnb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:cx="http://xmlcalabash.com/ns/extensions" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all" name="this">

  <p:documentation>
   Test driver pipeline for Print CSS experimentation 
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:document href="docbook-generic-print-css.xml"/>
  </p:input>


  <p:option name="debug" required="false" select="false()"/>

  <p:output port="result" primary="true" sequence="false">
    <!--<p:pipe port="result" step="step-output"/>-->
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../../xpl/xdoc-to-pdf.xpl"/>
  <p:import href="../../xpl/xdoc-to-xhtml.xpl"/>

  <!-- ======================================================================= -->

  <p:declare-step type="local:do-prince">
    <p:option name="href-in" required="true"/>
    <p:option name="href-out" required="true"/>
    <p:output port="result" primary="true" sequence="false"/>

    <p:variable name="arg-separator" select="'|'"/>
    <p:variable name="href-in-normalized" select="replace(resolve-uri($href-in, static-base-uri()), '^file:/+', '')"/>
    <p:variable name="href-out-normalized" select="replace(resolve-uri($href-out, static-base-uri()), '^file:/+', '')"/>

    <p:exec>
      <p:input port="source">
        <p:empty/>
      </p:input>
      <p:with-option name="command" select="'cmd'"/>
      <p:with-option name="args" select="string-join(('/C', 'prince', $href-in-normalized, '-o', $href-out-normalized), $arg-separator)"/>
      <p:with-option name="arg-separator" select="$arg-separator"/>
      <p:with-option name="result-is-xml" select="false()"/>
      <p:with-option name="wrap-result-lines" select="true()"/>
      <p:with-option name="wrap-error-lines" select="true()"/>
    </p:exec>

  </p:declare-step>

  <!-- ======================================================================= -->

  <p:variable name="build-dir" select="resolve-uri('build/', static-base-uri())"/>

  <p:variable name="href-xhtml" select="concat($build-dir, 'output.raw-xhtml.xml')"/>
  <p:variable name="href-pdf" select="concat($build-dir, 'output.print-css.pdf')"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- XSL-FO COnversion (for comparison): -->

  <xdoc:xdoc-to-pdf>
    <p:with-option name="href-pdf" select="concat($build-dir, 'output.xsl-fo.pdf')"/>
  </xdoc:xdoc-to-pdf>
  <p:sink/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Print CSS conversion: -->

  <xdoc:xdoc-to-xhtml name="step-output">
    <p:input port="source">
      <p:pipe port="source" step="this"/>
    </p:input>
  </xdoc:xdoc-to-xhtml>
  <p:wrap match="/*" wrapper="body"/>
  <p:wrap match="/*" wrapper="html"/>
  <p:insert match="/*" position="first-child">
    <p:input port="insertion">
      <p:inline>
        <head>
          <!-- TBD THIS IS A FIXED FILENAME! COMPUTE IT REL! -->
          <link rel="stylesheet" type="text/css" href="../styles.css"/>
        </head>
      </p:inline>
    </p:input>
  </p:insert>
  <p:namespace-rename from="" to="http://www.w3.org/1999/xhtml" apply-to="elements"/>
  <p:store method="xml" name="store-xhtml">
    <p:with-option name="href" select="$href-xhtml"/>
  </p:store>

  <local:do-prince cx:depends-on="store-xhtml">
    <p:with-option name="href-in" select="$href-xhtml"/>
    <p:with-option name="href-out" select="$href-pdf"/>
  </local:do-prince>


</p:declare-step>
