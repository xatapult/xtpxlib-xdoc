<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
      Turns an XML element description into the appropriate DocBook. An annotated schema for the element's description markup can be 
      found in `xsd/element-description.xml`.

      Typical usage (within an `xdoc` source document): 
      
      ```
      &lt;xdoc:transform href="$xdoc/xml-description.xpl&gt;
        &lt;xi:include href="path/to/xml/description.xml"/&gt;
      &lt;/xdoc:transform&gt;
      ```
      
  </p:documentation>

  <!-- 
   Remark: Since it is currently a single XSL only, we could have done this with an XSL only transformation. But Is think this
   is not the end of it and therefore I've put in a pipeline, so we can be flexible.
  -->
  
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The document containing the XML description, wrapped in an `xdoc:transform` element.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting DocBook output, containing the element's description.</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xml-description/do-element-description.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>

</p:declare-step>
