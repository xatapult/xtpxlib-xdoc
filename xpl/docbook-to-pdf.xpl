<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:pxf="http://exproc.org/proposed/steps/file" version="1.0" xpath-version="2.0"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" exclude-inline-prefixes="#all"
  type="xdoc:docbook-to-pdf">

  <p:documentation>
      This turns Docbook (5.1) into a PDF using FOP.
      
      All necessary `xdoc` pre-processing (usually with [xdoc-to-docbook.xpl](%xdoc-to-docbook.xpl)) must have been done.
      
      It will only convert a [partial DocBook tagset](%xdoc-docbook-dialect).
      
      If you don't use [xdoc-to-docbook.xpl](%xdoc-to-docbook.xpl), you have to make sure to get correct `xml:base` attributes in, so
      the pipeline can find includes and images. The following XProc (1.0) code takes care of that:

      ```
      <![CDATA[<p:xinclude>
        <p:with-option name="fixup-xml-base" select="true()"/> 
      </p:xinclude>
      <p:add-attribute attribute-name="xml:base" match="/*">
        <p:with-option name="attribute-value" select="/reference/to/source/document.xml"/>
      </p:add-attribute>]]>
      ```
      
    </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The docbook source document, fully expanded (with appropriate `xml:base` attributes)</p:documentation>
  </p:input>

  <p:option name="href-pdf" required="true">
    <p:documentation>The name of the resulting PDF file (must have `file://` in front).</p:documentation>
  </p:option>

  <p:option name="preliminary-version" required="false" select="false()">
    <p:documentation>If `true`, adds a preliminary version marker and output any `db:remark` elements. 
        If `false`, output of `db:remark` elements will be suppressed.</p:documentation>
  </p:option>

  <p:option name="chapter-id" required="false" select="''">
    <p:documentation>Specific chapter identifier to output.</p:documentation>
  </p:option>

  <p:option name="fop-config" required="false"
    select="resolve-uri('../../xtpxlib-common/data/fop-default-config.xml', static-base-uri())">
    <p:documentation>Reference to the FOP configuration file</p:documentation>
  </p:option>

  <p:option name="output-type" required="false" select="'a4'">
    <p:documentation>Output type. Use either `a4` or `sb` (= standard book size)</p:documentation>
  </p:option>

  <p:option name="main-font-size" required="false" select="10">
    <p:documentation>Main font size as an integer. Usual values somewhere between 8 and 10.</p:documentation>
  </p:option>

  <p:option name="global-resources-directory" required="false" select="()">
    <p:documentation>Images that are tagged as `role="global"` are searched here (discarding any directory information in the image's URI)</p:documentation>
  </p:option>

  <p:option name="href-xsl-fo" required="false" select="()">
    <p:documentation>If set, writes the intermediate XSL-FO to this href (so you can inspect it when things go wrong in FOP)</p:documentation>
  </p:option>
  
  <p:option name="create-pdf" required="false" select="true()">
    <p:documentation>Whether to actually create the PDF. If false, it will only output the XSL-FO</p:documentation>
  </p:option>
  
  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting XSL-FO (that was transformed into the PDF).</p:documentation>
    <p:pipe port="result" step="final-output"/>
  </p:output>

  <p:import href="../../xtpxlib-common/xplmod/common.mod/common.mod.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

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
  <xtlc:tee>
    <p:with-option name="href" select="$href-xsl-fo"/>
    <p:with-option name="indent" select="false()"/>
    <p:with-option name="enable" select="normalize-space($href-xsl-fo) ne ''"/>
  </xtlc:tee>

  <p:identity name="final-output"/>

  <!-- Make it into a PDF: -->
  <!-- 202201: There seems to be a problem with Calabash running FOP: Images no longer appear 
    and a bugfix is not forthcoming. 
    Therefore we try to do the trick by calling FOP directly...
  -->
  <!--<p:xsl-formatter name="step-create-pdf" content-type="application/pdf">
    <p:with-option name="href" select="$href-pdf"/>
    <!-\-<p:with-param name="UserConfig" select="replace($fop-config, '^file:/', '')"/>-\->
    <p:with-param name="null" select="()"/>
  </p:xsl-formatter>-->
  <p:group>
    <p:variable name="arg-separator" select="'|'"/>
    <p:variable name="fop"
      select="replace(resolve-uri('../../xtools/fop/fop.bat', static-base-uri()), '^file:/+?', '')"/>
    <p:variable name="args" select="string-join(
        ( '/C', $fop, 
          replace($href-xsl-fo, '^file:/+?', ''),     
          replace($href-pdf, '^file:/+?', '')
        ), 
        $arg-separator
    )"/>

    <!-- 202306: For some reason, Java (or FOP?) suddenly requires the PDF directory to exist. -->
    <p:variable name="href-pdf-dir" select="replace($href-pdf, '(.*)[/\\][^/\\]+$', '$1')"/>
    <pxf:mkdir>
      <p:with-option name="href" select="$href-pdf-dir"/>
    </pxf:mkdir>

    <p:exec>
      <p:input port="source">
        <p:empty/>
      </p:input>
      <p:with-option name="command" select="'cmd'"/>
      <p:with-option name="args" select="$args"/>
      <p:with-option name="arg-separator" select="$arg-separator"/>
      <p:with-option name="result-is-xml" select="false()"/>
      <p:with-option name="wrap-result-lines" select="true()"/>
      <p:with-option name="wrap-error-lines" select="true()"/>
    </p:exec>
    <p:sink/>
  </p:group>
  
</p:declare-step>
