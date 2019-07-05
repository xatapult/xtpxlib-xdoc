<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.utp_fmp_h3b"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false"/>
  <p:output port="result" primary="true" sequence="false"/>

  <!-- ================================================================== -->

  <p:identity>
    <p:input port="source">
      <p:inline>
        <xdoc:GROUP>
          <para>Line 1 from test.xpl</para>
          <para>Line 2 from test.xpl</para>
        </xdoc:GROUP>
      </p:inline>
    </p:input>
  </p:identity>

</p:declare-step>
