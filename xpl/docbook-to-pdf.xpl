<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all" type="xdoc:docbook-to-pdf">

  <p:documentation>
      This turns Docbook (5.1) into a PDF using FOP.
      
      All necessary pre-processing (resolving xincludes, expanding variables, examples, etc.) must have been done before this.
      To make sure we can find the images and other stuff, add appropriate xml:base attributes.
      
      It will only convert a partial DocBook tagset. See TBD.
      
      This is the code you would usually want to run before running this step, to get all the xml:base stuff right:
      
      <p:xinclude>
        <p:with-option name="fixup-xml-base" select="true()"/> 
      </p:xinclude>
      <p:add-attribute attribute-name="xml:base" match="/*">
        <p:with-option name="attribute-value" select="$dref-source"/>
      </p:add-attribute>
      
    </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The docbook source document, fully expanded (with appropriate xml:base attributes)</p:documentation>
  </p:input>

  <p:option name="dref-pdf" required="true">
    <p:documentation>The name of the resulting PDF file</p:documentation>
  </p:option>

  <p:option name="preliminary-version" required="false" select="false()">
    <p:documentation>If true, adds a preliminary version marker and output any db:remark elements. 
        If this is set to false, db:remark elements will be suppressed.</p:documentation>
  </p:option>

  <p:option name="chapter-id" required="false" select="''">
    <p:documentation>Specific chapter identifier to output (for debugging purposes)</p:documentation>
  </p:option>

  <p:option name="fop-config" required="false" select="resolve-uri('../../xtpxlib-common/data/fop-default-config.xml', static-base-uri())">
    <p:documentation>Reference to the FOP configuration file</p:documentation>
  </p:option>

  <p:option name="output-type" required="false" select="'a4'">
    <p:documentation>Output type. Use either a4 or sb (= standard book)</p:documentation>
  </p:option>

  <p:option name="main-font-size" required="false" select="10">
    <p:documentation>Main font size as an integer. Usual values somewhere between 8 and 10.</p:documentation>
  </p:option>
  
  <p:option name="global-resources-directory" required="false" select="()">
    <p:documentation>Images that are tagged as `role="global"` are searched here (discarding any directory information in the image's URI)</p:documentation>
  </p:option>
  
  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting XSL-FO that was transformed into the PDF</p:documentation>
    <p:pipe port="result" step="final-output"/>
  </p:output>

  <!-- ================================================================== -->

  <!-- Add identifiers and numbering: -->
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

  <!-- Handle columns with code contents and code width limitations 
    (<colspec role="code-width-cm:1.2-4"/> and <code role="code-width-limited">) -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-docbook-to-pdf/handle-code-width-limited-columns.xsl"/>
    </p:input>
    <p:with-param name="main-font-size" select="$main-font-size"/>
  </p:xslt>
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-docbook-to-pdf/handle-code-width-limited-contents.xsl"/>
    </p:input>
    <p:with-param name="main-font-size" select="$main-font-size"/>
  </p:xslt>

  <!-- Create the XSL-FO: -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-docbook-to-pdf/db5-to-xsl-fo.xsl"/>
    </p:input>
    <p:with-param name="preliminary-version" select="$preliminary-version"/>
    <p:with-param name="global-resources-directory" select="$global-resources-directory"/>
    <p:with-param name="chapter-id" select="$chapter-id"/>
    <p:with-param name="main-font-size" select="$main-font-size"/>
    <p:with-param name="output-type" select="$output-type"/>
  </p:xslt>

  <p:identity name="final-output"/>

  <p:xsl-formatter name="step-create-pdf" content-type="application/pdf">
    <p:with-option name="href" select="$dref-pdf"/>
    <p:with-param name="UserConfig" select="$fop-config"/>
  </p:xsl-formatter>

</p:declare-step>
