<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
     TBD
     
     @dir
     @filter
     @toc-only
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The triggering `xdoc:transform` element.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting DocBook output.</p:documentation>
  </p:output>
  <p:serialization port="result" indent="true" method="xml"/>

  <p:import href="../xplmod/xtpxlib-xdoc.mod/xtpxlib-xdoc.mod.xpl"/>
  <p:import href="../../xtpxlib-common/xplmod/common.mod/common.mod.xpl"/>
  <p:import href="code-docgen.xpl"/>

  <!-- ================================================================== -->

  <p:variable name="original-base-uri" select="base-uri(/)"/>
  <p:variable name="full-dir" select="resolve-uri(/*/@dir, $original-base-uri)"/>
  <p:variable name="filter" select="string(/*/@filter)"/>
  <p:variable name="toc-only" select="(/*/@toc-only, false())[1]"/>

  <p:identity name="original-source"/>

  <!-- Create a list of all files to process (filtering by this step is *weird*. We do our own filtering... -->
  <xtlc:recursive-directory-list flatten="true">
    <p:with-option name="path" select="$full-dir"/>
  </xtlc:recursive-directory-list>
  <p:identity name="directory-overview"/>

  <!-- Create a TOC: -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-code-docgen-dir/create-dir-overview.xsl"/>
    </p:input>
    <p:with-param name="full-dir" select="$full-dir"/>
    <p:with-param name="filter" select="$filter"/>
  </p:xslt>
  <xdoc:markdown-to-docbook/>
  <p:identity name="toc"/>
  <p:sink/>

  <!-- Now create the documentation for all separate modules: -->
  <p:identity>
    <p:input port="source">
      <p:pipe port="result" step="directory-overview"/>
    </p:input>
  </p:identity>
  <p:for-each>
    <p:iteration-source select="/*/c:file[($filter eq '') or matches(@name, $filter)][not(xs:boolean($toc-only))]"/>
    <p:variable name="href-file" select="/*/@href-abs"/>
    <p:load dtd-validate="false">
      <p:with-option name="href" select="$href-file"/>
    </p:load>
    <p:identity name="document-to-process"/>
    <p:sink/>
    
    <!-- Create a correct <xdoc:transform> element and process this: -->
    <p:identity>
      <p:input port="source">
        <p:inline>
          <xdoc:transform href="$xdoc/code-docgen.xpl"/>
        </p:inline>
      </p:input>
    </p:identity>
    <p:insert match="/*" position="first-child">
      <p:input port="insertion">
        <p:pipe port="result" step="document-to-process"/>
      </p:input>
    </p:insert>
    <p:set-attributes match="/*">
      <p:input port="attributes">
        <p:pipe port="result" step="original-source"/>
      </p:input>
    </p:set-attributes>
    <p:add-attribute attribute-name="xml:base" match="/*">
      <p:with-option name="attribute-value" select="$href-file"/>
    </p:add-attribute>
    <xdoc:code-docgen/>

  </p:for-each>
  <p:wrap-sequence wrapper="xdoc:GROUP"/>

  <!-- Insert the TOC into the result: -->
  <p:insert match="/*" position="first-child">
    <p:input port="insertion">
      <p:pipe port="result" step="toc"/>
    </p:input>
  </p:insert>
  
</p:declare-step>
