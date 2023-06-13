<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.blk_hqb_5xb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0" exclude-inline-prefixes="#all" type="xdoc:xdoc-to-docbook" name="xdoc-to-docbook">

  <p:documentation>
    XProc 3.0 pipeline that transforms a DocBook source containing `xdoc` extensions into "pure" DocBook format.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <!-- TBD -->

  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:document href="{resolve-uri('../test/xdoc-docbook-test-3.xml', static-base-uri())}" use-when="$develop"/>
    <p:documentation>The DocBook source with `xdoc` extensions</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The resulting DocBook.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-parameters" as="xs:string?" required="false" select="()" use-when="not($develop)">
    <p:documentation>
      Optional reference to a document with parameter settings. 
      See [here](https://common.xtpxlib.org/1_Description.html#parameters-explanation) for details.
    </p:documentation>
  </p:option>
  <p:option name="href-parameters" as="xs:string?" required="false" select="resolve-uri('../test/parameters.xml', static-base-uri())"
    use-when="$develop"/>

  <p:option name="parameter-filters-map" as="map(xs:string, xs:string)" required="false" select="map{}" use-when="not($develop)">
    <p:documentation>Optional filter settings for processing the parameters.</p:documentation>
  </p:option>
  <p:option name="parameter-filters-map" as="map(xs:string, xs:string)" required="false" select="map{}" use-when="$develop"/>

  <p:option name="alttarget" as="xs:string?" required="false" select="()">
    <p:documentation>The target for applying alternate settings.</p:documentation>
  </p:option>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Preparations: -->
  <p:variable name="base-uri-source" select="base-uri(/*)"/>
  <p:add-attribute attribute-name="xml:base" match="/*">
    <p:with-option name="attribute-value" select="$base-uri-source"/>
  </p:add-attribute>

  <!-- Process the XIncludes. But before that, check for parameter references in the 
    xi:include/@href attributes first. -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-docbook/substitute-parameters-xinclude-href.xsl"/>
    <p:with-option name="parameters" select="map{'href-parameters': $href-parameters, 'parameter-filters-map': $parameter-filters-map}"/>
  </p:xslt>
  <p:xinclude fixup-xml-base="true"/>

  <!-- Process any <xdoc:dump-parameters>: -->
  <p:viewport match="xdoc:dump-parameters">
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl-xdoc-to-docbook/dump-parameters.xsl"/>
      <p:with-option name="parameters" select="map{'href-parameters': $href-parameters, 'parameter-filters-map': $parameter-filters-map}"/>
    </p:xslt>
  </p:viewport>

  <!-- Substitute all parameter references: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-docbook/substitute-parameters.xsl"/>
    <p:with-option name="parameters" select="map{'href-parameters': $href-parameters, 'parameter-filters-map': $parameter-filters-map}"/>
  </p:xslt>

  <!-- Do the transforms: -->
  <!-- Remark: if any of these transformation wants to return multiple elements, 
               these should be wrapped in a <xdoc:GROUP> element. This
               element will be unwrapped before finishing.
  -->
  <p:viewport match="xdoc:transform" name="transform-viewport">

    <!-- Make the href attribute absolute and process the $xdoc indicator: -->
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl-xdoc-to-docbook/process-transform-href.xsl"/>
    </p:xslt>

    <p:variable name="href" as="xs:string" select="string(/*/@href)"/>
    <p:variable name="transformation-type" as="xs:string" select="string(/*/@xdoc:transformation-type)"/>

    <!-- Add the base URI of the source document as an attribute: -->
    <p:add-attribute attribute-name="xdoc:base-uri-source" match="/*">
      <p:with-option name="attribute-value" select="$base-uri-source"/>
    </p:add-attribute>
    <p:identity name="prepared-transform-element"/>

    <p:choose>

      <!-- XProc (3.0) pipeline: -->
      <p:when test="$transformation-type eq 'xproc3'">
        <p:run>
          <p:with-input href="{$href}"/>
          <p:run-input port="source" primary="true" pipe="@prepared-transform-element"/>
          <p:output port="result" primary="true"/>
        </p:run>
      </p:when>

      <!-- XSLT transformation: -->
      <p:when test="$transformation-type eq 'xslt'">
        <p:xslt>
          <p:with-input port="source" pipe="@prepared-transform-element"/>
          <p:with-input port="stylesheet" href="{$href}"/>
        </p:xslt>
      </p:when>

      <!-- Unrecognized, should not occur: -->
      <p:otherwise>
        <p:error code="xdoc:error">
          <p:with-input>
            <p:inline content-type="text/plain">Internal error: unrecognized transformation type: &quot;{$transformation-type}&quot;</p:inline>
          </p:with-input>
        </p:error>
      </p:otherwise>

    </p:choose>

    <!-- Force everything into the docbook namespace: -->
    <p:namespace-rename apply-to="elements" from="" to="http://docbook.org/ns/docbook"/>

  </p:viewport>

  <!--  Remove grouping with <xdoc:GROUP> elements: -->
  <p:unwrap match="xdoc:GROUP"/>

  <!-- Substitute all parameter references again (in case the transforms generated 
       something that included a parameter reference): -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-docbook/substitute-parameters.xsl"/>
    <p:with-option name="parameters" select="map{'href-parameters': $href-parameters, 'parameter-filters-map': $parameter-filters-map}"/>
  </p:xslt>

  <!-- Handle any alt specs: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-docbook/process-alt-settings.xsl"/>
    <p:with-option name="parameters" select="map{'alttarget': $alttarget }"/>
  </p:xslt>

  <!-- Remove any not handled xdoc stuff: -->
  <p:delete match="xdoc:*"/>
  <p:delete match="@xdoc:*"/>

</p:declare-step>
