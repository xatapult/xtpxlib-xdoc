<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.pfs_dr3_h3b"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:cx="http://xmlcalabash.com/ns/extensions" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all" type="xdoc:xdoc-to-docbook">

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
    <p:documentation>Filter settings for processing the parameters. Format: "name=value|name=value|..."</p:documentation>
  </p:option>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting DocBook</p:documentation>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <!-- ================================================================== -->

  <!-- Add a specific xml:base attribute to the root element. Otherwise base-uri computations somehow don't return the right value... -->
  <p:add-attribute attribute-name="xml:base" match="/*">
    <p:with-option name="attribute-value" select="base-uri(/*)"/>
  </p:add-attribute>

  <!-- Process the XIncludes. But before that, check for parameter references in the xi:include/@href attributes first. -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-docbook/substitute-parameters-xinclude-href.xsl"/>
    </p:input>
    <p:with-param name="href-parameters" select="$href-parameters"/>
    <p:with-param name="parameter-filters" select="$parameter-filters"/>
  </p:xslt>
  <p:xinclude>
    <p:with-option name="fixup-xml-base" select="true()"/>
  </p:xinclude>
  
  <!-- Process any <xdoc:dump-parameters>: -->
  <p:viewport match="xdoc:dump-parameters">
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl-xdoc-to-docbook/dump-parameters.xsl"/>
      </p:input>
      <p:with-param name="href-parameters" select="$href-parameters"/>
      <p:with-param name="parameter-filters" select="$parameter-filters"/>
    </p:xslt>
  </p:viewport>

  <!-- Substitute all parameter references: -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-docbook/substitute-parameters.xsl"/>
    </p:input>
    <p:with-param name="href-parameters" select="$href-parameters"/>
    <p:with-param name="parameter-filters" select="$parameter-filters"/>
  </p:xslt>

  <!-- Do the transforms: -->
  <!-- Remark: if any of these transformation wants to return multiple elements, these should be wrapped in a <xdoc:GROUP> element. This
       element will be unwrapped before finishing.
  -->
  <p:viewport match="xdoc:transform" name="transform-viewport">

    <!-- Make the href attribute absolute and process the $xdoc indicator: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl-xdoc-to-docbook/process-transform-href.xsl"/>
      </p:input>
      <p:with-param name="null" select="()"/>
    </p:xslt>
    <p:identity name="prepared-transform-element"/>

    <p:group>
      <p:variable name="href" select="/*/@href"/>
      <p:variable name="transformation-type" select="/*/@xdoc:transformation-type"/>
      <p:choose>

        <!-- XProc (1.0) pipeline: -->
        <p:when test="$transformation-type eq 'xproc1'">
          <!-- Get the pipeline on board: -->
          <p:load dtd-validate="false" name="loaded-pipeline">
            <p:with-option name="href" select="$href"/>
          </p:load>
          <!-- Run it:  -->
          <cx:eval>
            <p:input port="source">
              <p:pipe port="result" step="prepared-transform-element"/>
            </p:input>
            <p:input port="pipeline">
              <p:pipe port="result" step="loaded-pipeline"/>
            </p:input>
            <p:input port="options">
              <p:inline exclude-inline-prefixes="#all">
                <!-- No options. -->
                <cx:options/>
              </p:inline>
            </p:input>
          </cx:eval>
        </p:when>

        <!-- XSLT transformation: -->
        <p:when test="$transformation-type eq 'xslt'">
          <!-- Get the XSL on board: -->
          <p:load dtd-validate="false" name="loaded-xsl">
            <p:with-option name="href" select="$href"/>
          </p:load>
          <!-- Run it:  -->
          <p:xslt>
            <p:input port="source">
              <p:pipe port="result" step="prepared-transform-element"/>
            </p:input>
            <p:input port="stylesheet">
              <p:pipe port="result" step="loaded-xsl"/>
            </p:input>
            <p:with-param name="null" select="()"/>
          </p:xslt>
        </p:when>

        <!-- Unrecognized, should not occur: -->
        <p:otherwise>
          <p:variable name="error"
            select="error((), concat('Internal error: unrecognized transformation type: &quot;', $transformation-type, '&quot;')) "/>
          <p:identity/>
        </p:otherwise>

      </p:choose>

      <!-- Force everything into the docbook namespace: -->
      <p:namespace-rename apply-to="elements" from="" to="http://docbook.org/ns/docbook"/>

    </p:group>
  </p:viewport>

  <!--  Remove grouping with <xdoc:GROUP> elements: -->
  <p:unwrap match="xdoc:GROUP"/>

  <!-- Substitute all parameter references again (in case the transforms generated something that included a parameter reference): -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-docbook/substitute-parameters.xsl"/>
    </p:input>
    <p:with-param name="href-parameters" select="$href-parameters"/>
    <p:with-param name="parameter-filters" select="$parameter-filters"/>
  </p:xslt>
  
</p:declare-step>
