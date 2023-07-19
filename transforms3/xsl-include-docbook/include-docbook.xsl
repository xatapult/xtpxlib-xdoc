<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.y1s_bd4_5jb"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Looks at the children of the root xdoc:transform element:
       * If its a db:article or db:book, it will include all children with the exception of db:info
       * If its anything else it will include all its children. You'll have to make sure its in the right (Docbook) namespace!
       
       Set an attribute unwrap-first="true" to unwrap the first child, including remopval of an optional db:title element.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->



  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->



  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/"> </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->



</xsl:stylesheet>
