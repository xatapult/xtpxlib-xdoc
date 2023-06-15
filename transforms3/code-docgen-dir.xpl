<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-inline-prefixes="#all"
  type="xdoc:code-docgen-dir">

  <p:documentation>
      Runs the `[$xdoc/code-docgen.xpl](%code-docgen.xpl)` transform over multiple files in a directory. 
      
      Typical usage (within an `xdoc` source document): 
      
      ```
      &lt;xdoc:transform href="$xdoc/code-docgen-dir.xpl"
         dir="…" 
         depth="…"
         filter="…" 
         toc-only="…"
         id-suffix="…" &gt;
      ```
      
      - `@dir`: Directory to process
      - `@depth`: (integer, default -1) The depth in traversing the directory tree.
        - When le 0, `@dir` and all its subdirectories are processed.
        - When eq 1, only `@dir` is processed.
        - When gt 1, the sub-directories up to this depth are processed.
      - `@filter`: optional regexp filter (e.g. get only XProc files with `filter="\.xpl$"`)
      - `@toc-only`: (boolean, default `false`) Whether to produce a ToC table only.
      - `@id-suffix`: Optional suffix for creating an id based on the filename.      
        
      All (other) attributes are passed to `code-docgen.xpl`.        
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:import href="../../xtpxlib-common/xpl3mod/recursive-directory-list/recursive-directory-list.xpl"/>
  <p:import href="../xpl3mod/xtpxlib-xdoc.mod/xtpxlib-xdoc.mod.xpl"/>
  <p:import href="code-docgen.xpl"/>

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The triggering `xdoc:transform` element.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting DocBook output.</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <p:variable name="original-base-uri" as="xs:string" select="base-uri(/)"/>
  <p:variable name="full-dir" as="xs:string" select="resolve-uri(/*/@dir, $original-base-uri)"/>
  <p:variable name="filter" as="xs:string" select="string(/*/@filter)"/>
  <p:variable name="toc-only" as="xs:boolean" select="xs:boolean((/*/@toc-only, false())[1])"/>
  <p:variable name="depth" as="xs:integer" select="xs:integer((/*/@depth, -1)[1])"/>
  <p:variable name="id-suffix" as="xs:string" select="string(/*/@id-suffix)"/>

  <p:identity name="original-source"/>

  <!-- Create a list of all files to process (filtering by this step is *weird*. We do our own filtering...) -->
  <xtlc:recursive-directory-list flatten="true">
    <p:with-option name="path" select="$full-dir"/>
    <p:with-option name="depth" select="if ($depth eq 0) then -1 else $depth"/>
  </xtlc:recursive-directory-list>
  <p:identity name="directory-overview"/>

  <!-- Create a TOC: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-code-docgen-dir/create-dir-overview.xsl"/>
    <p:with-option name="parameters" select="map{'full-dir': $full-dir, 'filter': $filter, 'id-suffix': $id-suffix}"/>
  </p:xslt>
  <xdoc:markdown-to-docbook/>
  <p:identity name="toc"/>
  <p:sink/>

  <!-- Now create the documentation for all separate modules. We do this by creating a "fake" xdoc:transform XML fragment to $xdoc/code-docgen and run this. -->
  <p:identity>
    <p:with-input port="source" pipe="@directory-overview"/>
  </p:identity>
  <p:for-each>
    <p:with-input select="/*/c:file[($filter eq '') or matches(@name, $filter)][not(xs:boolean($toc-only))]"/>
    <p:variable name="href-file" as="xs:string" select="string(/*/@href-abs)"/>
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl-code-docgen-dir/create-docgen-request.xsl"/>
      <p:with-option name="parameters" select="map{'href-file': $href-file}"/>
    </p:xslt>
    <xdoc:code-docgen/>
  </p:for-each>
  <p:wrap-sequence wrapper="xdoc:GROUP"/>

  <!-- Insert the TOC into the result: -->
  <p:insert match="/*" position="first-child">
    <p:with-input port="insertion" pipe="@toc"/>
  </p:insert>

</p:declare-step>
