<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all" type="xdoc:docbook-to-pdf-print-css">

  <p:documentation>
      This turns Docbook (5.1) into a PDF using a Print CSS processor.
      
      The only processor currently supported is Prince.
      
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

  <!-- TBD SUPPORT FOR NOW COMMENTED OUT OPTIONS?!? -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The docbook source document, fully expanded (with appropriate `xml:base` attributes)</p:documentation>
  </p:input>

  <p:option name="href-pdf" required="true">
    <p:documentation>The name of the resulting PDF file (must have `file://` in front).</p:documentation>
  </p:option>

  <!-- <p:option name="preliminary-version" required="false" select="false()">
    <p:documentation>If `true`, adds a preliminary version marker and output any `db:remark` elements. 
        If `false`, output of `db:remark` elements will be suppressed.</p:documentation>
  </p:option>-->

  <!--<p:option name="chapter-id" required="false" select="''">
    <p:documentation>Specific chapter identifier to output.</p:documentation>
  </p:option>-->

  <p:option name="print-css-processor" required="false" select="'prince'">
    <p:documentation>Which Print CSS procssor to use. Hard-wired values, currently only `prince` is supported.</p:documentation>
  </p:option>

  <p:option name="href-css" required="false" select="resolve-uri('../resources/print-css-1/styles-a4.css', static-base-uri())">
    <p:documentation>Reference to the Print CSS file to use. Use absolute references only.</p:documentation>
  </p:option>

  <!--<p:option name="global-resources-directory" required="false" select="()">
    <p:documentation>Images that are tagged as `role="global"` are searched here (discarding any directory information in the image's URI)</p:documentation>
  </p:option>-->

  <p:option name="href-xhtml" required="true">
    <p:documentation>Location for the (intermediate) XHTML</p:documentation>
  </p:option>

  <p:output port="result" primary="true" sequence="false">
    <p:pipe port="result" step="xhtml-before-print-css-processing"></p:pipe>
    <p:documentation>The resulting XSL-FO (that was transformed into the PDF).</p:documentation>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>
  
  <p:import href="../../xtpxlib-common/xplmod/common.mod/common.mod.xpl"/>
  
  <p:variable name="arg-separator" select="'|'"/>

  <p:variable name="href-in-normalized" select="replace($href-xhtml, '^file:/+', '')"/>
  <p:variable name="href-out-normalized" select="replace($href-pdf, '^file:/+', '')"/>

  <!-- ================================================================== -->

  <!-- Add a specific xml:base attribute to the root element. Otherwise base-uri computations somehow don't return the right value... -->
  <p:add-attribute attribute-name="xml:base" match="/*">
    <p:with-option name="attribute-value" select="base-uri(/*)"/>
  </p:add-attribute>
  
  <!-- Create the input XHTML: -->
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
  
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-docbook-to-pdf-print-css/db5-to-xhtml-for-print-css.xsl"/>
    </p:input>
    <p:with-param name="href-css" select="$href-css"/>
    <p:with-param name="print-css-processor" select="$print-css-processor"/>
  </p:xslt>
  <p:identity name="xhtml-before-print-css-processing"></p:identity>
  
  <!-- Store it (this *must* be done, because the Print CSS processor expects it on disk): -->
  <p:store indent="true" method="xml" name="store-xhtml">
    <p:with-option name="href" select="$href-xhtml"/>
  </p:store>

  <!-- Turn it in to PDF: -->
  <p:identity>
    <p:input port="source">
      <p:pipe port="result" step="xhtml-before-print-css-processing"/>
    </p:input>
  </p:identity>
  <p:choose>

    <!-- Prince: -->
    <p:when test="$print-css-processor eq 'prince'">
      <p:exec cx:depends-on="store-xhtml">
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
    </p:when>

    <!-- Don't know what to do: -->
    <p:otherwise>
      <p:error code="xtlc:print-css-processor">
        <p:input port="source">
          <p:inline>
            <message>Unrecognized Print CSS processor name</message>
          </p:inline>
        </p:input>
      </p:error>
    </p:otherwise>

  </p:choose>
  <p:sink/>

</p:declare-step>
