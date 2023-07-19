<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.szy_4kg_2jb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:db="http://docbook.org/ns/docbook" version="3.0"  exclude-inline-prefixes="#all">

  <p:documentation>
    Library with support pipelines for `xdoc` and related conversions.
  </p:documentation>

  <!-- ================================================================== -->

  <p:declare-step type="xdoc:markdown-to-docbook">

    <p:documentation>
      Converts the contents of `xdoc:MARKDOWN` elements into DocBook.
      
      This pipeline checks the incoming XML for `xdoc:MARKDOWN` elements. The contents of these elements is assumed to contain Markdown. The
      pipeline tries to convert this into DocBook. The `xdoc:MARKDOWN` element is removed/unwrapped.
      
      The following rules apply:
      * The contents of an `xdoc:MARKDOWN` element is stringified (so any child elements are lost).
      * The resulting text can be indented, using space characters only (no tabs!). The non-empty line with the *minimum* indent is assumed to be its left margin. 
      * Only simple Markdown is supported. Specifically:
        * Inline markup for emphasis, bold, code, etc.
        * Links. A link target starting with a `%` is handled as an *internal* link (the `@xml:id` of something in the encompassing DocBook).
        * Code blocks (using three consecutive back-ticks)
        * Headers (these are all converted into the same DocBook `bridgehead` elements)
      * Specifically not supported (yet?) are tables.
      
      If you add an `header-only="true"` attribute to the `xdoc:MARKDOWN` element, only the first paragraph will be output. 
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- SETUP: -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation>Any XML that might contain `xdoc:MARKDOWN` elements for conversion.</p:documentation>
    </p:input>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>The same XML but with the `xdoc:MARKDOWN` element's contents converted into DocBook.</p:documentation>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:viewport match="xdoc:MARKDOWN">

      <!-- Turn everything into lines: -->
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-markdown-to-docbook/convert-to-lines.xsl"/>
      </p:xslt>

      <!-- Group lines into paragraphs: -->
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-markdown-to-docbook/group-lines.xsl"/>
      </p:xslt>

      <!-- Handle inline markup (like `code`, *italic*, etc.): -->
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-markdown-to-docbook/process-inlines.xsl"/>
      </p:xslt>

      <!-- List handling: -->
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-markdown-to-docbook/handle-lists.xsl"/>
      </p:xslt>
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-markdown-to-docbook/handle-lists-finalize.xsl"/>
      </p:xslt>

    </p:viewport>

    <!-- Remove the trigger element: -->
    <p:unwrap match="xdoc:MARKDOWN"/>

  </p:declare-step>

</p:library>
