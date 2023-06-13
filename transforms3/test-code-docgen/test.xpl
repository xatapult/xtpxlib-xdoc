<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all" type="xdoc:blablabla">

  <p:documentation>
      TBD *a bit more* `code code`
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The document to generate documentation for, wrapped in an xdoc:transform element.</p:documentation>
  </p:input>
  
 
  <p:output port="result"  sequence="false">
    <p:documentation>The resulting docbook 5 output</p:documentation>
  </p:output>
  
  <p:input port="aux">
    
  </p:input>
  
  <p:option name="xdoc:blabla" required="false" select="'xyzbla bla bla bla bla'" >
    <p:documentation>More bla</p:documentation>
  </p:option>
  
  <p:option name="xdoc:blabla2" required="true"  >
    <p:documentation>
      More bla 222
      - xx
    </p:documentation>
  </p:option>
  
  <!-- ================================================================== -->

  <!-- Turn the thing to document into intermediate format: -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl/document-to-docgen-intermediate.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>
  <p:identity name="docgen-intermediate"/>
  
  <!-- Validate this (comment-out when not developing): -->
  <p:validate-with-xml-schema>
    <p:input port="schema">
      <p:document href="xsd/docgen-intermediate.xsd"/>
    </p:input>
  </p:validate-with-xml-schema>
  <p:sink/>
  
  <!-- Make it into DocBook: -->
  <p:xslt>
    <!-- Remark: We read the input from before the intermediate format was validated. Otherwise we get a PSVI annotated version 
      of it which breaks the XSLT... -->
    <p:input port="source">
      <p:pipe port="result" step="docgen-intermediate"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="xsl/docgen-intermediate-to-docbook.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>
  
</p:declare-step>
