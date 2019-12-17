<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns="http://docbook.org/ns/docbook">

  <xsl:template match="/">
    <table>
      <title>Example weather data</title>
      <tgroup cols="2">
        <colspec colwidth="4cm"/>
        <colspec/>
        <thead>
          <row>
            <entry>
              <para>City</para>
            </entry>
            <entry>
              <para>Temperature (C)</para>
            </entry>
          </row>
        </thead>
        <tbody>
          <xsl:for-each select="/xdoc:transform/weather-data/data">
            <row>
              <entry>
                <para>
                  <xsl:value-of select="@city"/>
                </para>
              </entry>
              <entry>
                <para><xsl:value-of select="@temp"/></para>
              </entry>
            </row>
          </xsl:for-each>
        </tbody>
      </tgroup>
    </table>
  </xsl:template>

</xsl:stylesheet>
