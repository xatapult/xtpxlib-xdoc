<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all" type="xdoc:xdoc-to-componentdoc-website">

  <p:documentation>
     Creates a documentation website for a component from an xdoc book style document.
     Relative names are resolved against the base URI of the *source document*.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The DocBook source with xdoc extensions to create the website from</p:documentation>
  </p:input>

  <p:option name="href-parameters" required="false" select="()">
    <p:documentation>Reference to an optional document with parameter settings. See the xtpxlib-common parameters.mod.xsl module for details.</p:documentation>
  </p:option>

  <p:option name="parameter-filters" required="false" select="()">
    <p:documentation>Filter settings for processing the parameters. Format: "name=value|name=value|..."</p:documentation>
  </p:option>

  <p:option name="resources-subdirectory" required="false" select="()">
    <p:documentation>The *relative* name of the subdirectory that contains specific resources (like CSS, images, etc.) for this component.</p:documentation>
  </p:option>

  <p:option name="global-resources-directory" required="false" select="()">
    <p:documentation>The name of the subdirectory that contains global resources (resources used for documenting a group of components).</p:documentation>
  </p:option>

  <p:option name="output-directory" required="true" >
    <p:documentation>The name of the output directory for the generated website.</p:documentation>
  </p:option>

  <p:option name="href-template" required="true" >
    <p:documentation>TBD</p:documentation>
  </p:option>

  <p:option name="component-name" required="true">
    <p:documentation>The name of the component (e.g. `xtpxlib-xdoc`) for which the documentation is generated.</p:documentation>
  </p:option>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>TBD???</p:documentation>
    <p:pipe port="result" step="end-result"/>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="xdoc-to-docbook.xpl"/>
  <p:import href="docbook-to-xhtml.xpl"/>
  <p:import href="docbook-to-pdf.xpl"/>
  <p:import href="../../xtpxlib-common/xplmod/common.mod/common.mod.xpl"/>
  <p:import href="../../xtpxlib-container/xplmod/container.mod/container.mod.xpl"/>

  <!-- ================================================================== -->

  <!-- Make sure all relative directory and file names are resolved against the directory of the source document: -->
  <p:variable name="base-uri-source-document" select="base-uri(/)"/>
  <p:variable name="full-href-parameters" select="resolve-uri($href-parameters, $base-uri-source-document)"/>
  <p:variable name="full-resources-source-directory" select="resolve-uri($resources-subdirectory, $base-uri-source-document)"/>
  <p:variable name="full-global-resources-directory" select="resolve-uri($global-resources-directory, $base-uri-source-document)"/>
  <p:variable name="full-output-directory" select="resolve-uri($output-directory, $base-uri-source-document)"/>
  <p:variable name="full-resources-target-directory" select="string-join(($full-output-directory, $resources-subdirectory), '/')"/>
  <p:variable name="full-href-template" select="resolve-uri($href-template, $base-uri-source-document)"/>
  
  <!-- Definitions for the PDF version: -->
  <p:variable name="pdf-filename" select="concat(replace($component-name, '[^A-Za-z0-9\-.]', '_'), '-documentation.pdf')"/>
  <p:variable name="pdf-relative-href" select="string-join(($resources-subdirectory, $pdf-filename), '/')"/>
  <p:variable name="pdf-absolute-href" select="string-join(($full-output-directory, $pdf-relative-href), '/')"/>

  <!-- Turn the xdoc source into Docbook: -->
  <xdoc:xdoc-to-docbook>
    <p:with-option name="href-parameters" select="$full-href-parameters"/>
    <p:with-option name="parameter-filters" select="$parameter-filters"/>
  </xdoc:xdoc-to-docbook>
  <p:identity name="docbook-contents"/>

  <!-- Now create the XHTML version: -->
  <xdoc:docbook-to-xhtml>
    <p:with-option name="create-header" select="true()"/>
  </xdoc:docbook-to-xhtml>

  <!-- Create an xtpxlib-container structure for writing the XHTML results:. -->
  <!-- WARNING: This assumes there are no double titles. Normally this won't be the case because all prefaces/chapters/appendices 
    are numbered. But... decisions about naming and numbering might influence that. We'll pas that bridge when we stumble upon it.
  -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-componentdoc-website/create-basic-container.xsl"/>
    </p:input>
    <p:with-param name="href-target-path" select="$full-output-directory"/>
    <p:with-param name="href-componentdoc-website-template" select="$full-href-template"/>
  </p:xslt>
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-componentdoc-website/fix-internal-links.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>
  

  <!-- Add internal linking between the pages (TOC, etc.): -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-componentdoc-website/add-additional-links.xsl"/>
    </p:input>
    <p:with-param name="pdf-href" select="$pdf-relative-href"/>
  </p:xslt>

  <!-- Insert directory information for the resources and re-work this to the right container external document entries: -->
  <!-- Remark: the global list is inserted before the specific one, so you can override files from it with ones from the specific directory. -->
  <p:insert match="/*" position="first-child">
    <p:input port="insertion">
      <p:pipe port="result" step="resources-directory-list"/>
    </p:input>
  </p:insert>
  <p:insert match="/*" position="first-child">
    <p:input port="insertion">
      <p:pipe port="result" step="global-resources-directory-list"/>
    </p:input>
  </p:insert>
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-componentdoc-website/rework-resources-directory-list.xsl"/>
    </p:input>
    <p:with-param name="resources-target-directory" select="$full-resources-target-directory"/>
  </p:xslt>

  <!-- Write the result out to disk: -->
  <xtlcon:container-to-disk/>
  <p:identity name="end-result"/>
  
  <!-- Create the PDF version of the documentation also: -->
  <xdoc:docbook-to-pdf>
    <p:input port="source">
      <p:pipe port="result" step="docbook-contents"/>
    </p:input>
    <p:with-option name="dref-pdf" select="$pdf-absolute-href"/> 
  </xdoc:docbook-to-pdf>
  <p:sink/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Subpipeline to get the contents of the specific resources directory: -->

  <xtlc:recursive-directory-list>
    <p:with-option name="path" select="$full-resources-source-directory"/>
    <p:with-option name="flatten" select="true()"/>
  </xtlc:recursive-directory-list>
  <p:identity name="resources-directory-list"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Subpipeline to get the contents of the global resources directory: -->

  <p:choose>
    <p:when test="$global-resources-directory ne ''">
      <xtlc:recursive-directory-list>
        <p:with-option name="path" select="$full-global-resources-directory"/>
        <p:with-option name="flatten" select="true()"/>
      </xtlc:recursive-directory-list>
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source">
          <p:inline>
            <c:directory/>
          </p:inline>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
  <p:identity name="global-resources-directory-list"/>

</p:declare-step>
