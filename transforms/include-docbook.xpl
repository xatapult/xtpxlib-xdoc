<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns:db="http://docbook.org/ns/docbook" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
      Takes an XML document and unwraps the root element from it. It then copies all the children to the output, with the exception of any 
      `db:info` elements. 
      
      It is the responsibility of the author to make sure that everything that results is in the DocBook (`http://docbook.org/ns/docbook`) namespace!
      
      Typical usage (within an `xdoc` source document): 
      
      ```
      &lt;xdoc:transform href="$xdoc/include-docbook.xpl&gt;
        &lt;xi:include href="path/to/xml/to/include.xml"/&gt;
      &lt;/xdoc:transform&gt;
      ```
      
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The document containing the parts to include, wrapped in an `xdoc:transform` element.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting DocBook output.</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <!-- Unwrap the xdoc:transform and the root element of the document: -->
  <p:for-each>
    <p:iteration-source select="/*/*/* except /*/*/db:info"/>
    <p:identity/>
  </p:for-each>
  <p:wrap-sequence wrapper="xdoc:GROUP"/>

</p:declare-step>
