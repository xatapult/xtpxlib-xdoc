<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  version="3.0" exclude-inline-prefixes="#all" type="xdoc:code-docgen">

  <p:documentation>
      Takes an XML document (XSL, XSD, XProc, ordinary XML) and generates documentation out of it. 
      
      Typical usage (within an `xdoc` source document): 
      
      ```
      &lt;xdoc:transform href="$xdoc/code-docgen.xpl"
         filecomponents="…" 
         header-level="…" 
         add-table-titles="…"
         sublevels="…"
         id="…" 
         id-suffix="…" &gt;
        &lt;xi:include href="path/to/document/to/generate/documentation/for"/&gt;
      &lt;/xdoc:transform&gt;
      ```
      
      - `@filecomponents`: (integer, default 0)Determines the display of the filename:
        - When lt 0, no filename is displayed
        - When eq 0, the full filename (with full path) is displayed
        - When gt 0, this number of filename components is displayed. So 1 means filename only, 2 means filename and direct foldername, etc.
      - `@header-level`: (integer, default 0)Determines what kind of DocBook section is created:
        - When le 0, no separate section is created, all titles will be output as `bridgehead` elements.
        - Otherwise a title with this level is created (e.g. `header-level="1"` means a `sect1` element).
      - `@add-table-titles`: (boolean, default `false`) Whether to add titles to generated tables.
      - `@sublevels`: (boolean, default `true`) If true only the main section will be a "real" section. All sublevels will become bridgeheads.
      - `@id`: Optional identifier of this section. If absent the id will become the document's filename, optionally suffixed with `@id-suffix`.
      - `@id-suffix`: Optional suffix for creating an id based on the filename.
        
      If the format to document has  means to add documentation of itself (like XProc (`p:documentation`) or XML Schema (`xs:annotation`)), 
      this is used. If there is no such thing (like for XSLT and straight XML), comments starting with a tilde (`~`) are used. 
      
      All descriptions and documentation sections can contain simple Markdown.
      
      The following formats are supported  
      - XML documents: only the header comment is used.
      - XSLT (2.0 and 3.0) stylesheets: document all *exported* parameters, variables, functions and named templates. Something is supposed to be for export if its *not* in the no or local namespace.
      - XProc pipelines and libraries
      - XML Schemas: Uses the global annotation and lists the global elements using their annotations.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:import href="../xpl3mod/xtpxlib-xdoc.mod/xtpxlib-xdoc.mod.xpl"/>

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The document to generate documentation for, wrapped in an `xdoc:transform` element.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting DocBook output.</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-code-docgen/code-docgen.xsl"/>
  </p:xslt>

  <!-- Resolve any Markdown stuff: -->
  <xdoc:markdown-to-docbook/>

</p:declare-step>
