<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
     Just tries the FO transform using FOP
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="href-xsl-fo" required="false" select="resolve-uri('test-fo.xml', static-base-uri())"/>
  
  <p:option name="href-pdf" required="false" select="resolve-uri('../tmp/test-fo.pdf', static-base-uri())"/>
  
  <!-- ================================================================== -->

  <p:variable name="arg-separator" select="'|'"/>
  <p:variable name="fop"
    select="replace(resolve-uri('../../xtools/fop/fop.bat', static-base-uri()), '^file:/+?', '')"/>
  <p:variable name="args" select="string-join(
      ( '/C', $fop, 
        replace($href-xsl-fo, '^file:/+?', ''),     
        replace($href-pdf, '^file:/+?', '')
      ), $arg-separator
    )"/>
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

</p:declare-step>
