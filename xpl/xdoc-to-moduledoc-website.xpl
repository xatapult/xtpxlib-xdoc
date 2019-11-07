<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all" type="xdoc:xdoc-to-moduledoc-website">

  <p:documentation>
     Creates a documentation website for a module from an xdoc book style document.
     Relative names are resolved against the base URI of the source document.
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

  <p:option name="resources-source-subdirectory" required="false" select="'resources'">
    <p:documentation>The name of the subdirectory that contains the resources (like CSS, images, etc.).</p:documentation>
  </p:option>

  <p:option name="resources-target-subdirectory" required="false" select="'resources'">
    <p:documentation>The *relative* name of subdirectory that will contain the resources (like CSS, images, etc.).</p:documentation>
  </p:option>

  <p:option name="output-directory" required="false" select="'../docs'">
    <p:documentation>The name of the output directory for this website. 
      If not set it is the (GitHub pages standard) docs directory.</p:documentation>
  </p:option>

  <p:option name="href-template" required="false" select="'moduledoc-website-template.html'">
    <p:documentation/>
  </p:option>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>TBD???</p:documentation>
    <p:pipe port="result" step="end-result"/>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="xdoc-to-xhtml.xpl"/>
  <p:import href="../../xtpxlib-common/xplmod/common.mod/common.mod.xpl"/>
  <p:import href="../../xtpxlib-container/xplmod/container.mod/container.mod.xpl"/>

  <!-- ================================================================== -->

  <p:variable name="full-href-parameters" select="resolve-uri($href-parameters, base-uri(/))"/>
  <p:variable name="full-resources-source-subdirectory" select="resolve-uri($resources-source-subdirectory, base-uri(/))"/>
  <p:variable name="full-output-directory" select="resolve-uri($output-directory, base-uri(/))"/>
  <p:variable name="full-href-template" select="resolve-uri($href-template, base-uri(/))"/>

  <xdoc:xdoc-to-xhtml>
    <p:with-option name="href-parameters" select="$full-href-parameters"/>
    <p:with-option name="parameter-filters" select="$parameter-filters"/>
    <p:with-option name="create-header" select="false()"/>
    <p:with-option name="base-href" select="$resources-target-subdirectory"/>
  </xdoc:xdoc-to-xhtml>

  <!-- Create a basic container structure. -->
  <!-- WARNING: This assumes there are no double titles. Normally this won't be the case because all prefaces/chapters/appendices 
    are numbered. But... decisions about naming and numbering might influence that. We'll pas that bridge when we stumble upon it.-->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-moduledoc-website/create-basic-container.xsl"/>
    </p:input>
    <p:with-param name="href-target-path" select="$full-output-directory"/>
    <p:with-param name="href-moduledoc-website-template" select="$full-href-template"/>
  </p:xslt>
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-moduledoc-website/fix-internal-links.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>

  <!-- Insert directory information for the resources and re-qork this to the right container external document entries: -->
  <p:insert match="/*" position="first-child">
    <p:input port="insertion">
      <p:pipe port="result" step="resources-directory-list"/>
    </p:input>
  </p:insert>
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-moduledoc-website/rework-resources-directory-list.xsl"/>
    </p:input>
    <p:with-param name="resources-target-subdirectory" select="$resources-target-subdirectory"/>
  </p:xslt>
  
  <!-- Write the result out to disk: -->
  <xtlcon:container-to-disk/>
  <p:identity name="end-result"/>
  <p:sink/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xtlc:recursive-directory-list>
    <p:with-option name="path" select="$full-resources-source-subdirectory"/>
    <p:with-option name="flatten" select="true()"/>
  </xtlc:recursive-directory-list>
  <p:identity name="resources-directory-list"/>

</p:declare-step>
