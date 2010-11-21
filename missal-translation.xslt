<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="translation.xslt"/>
	<xsl:output method="xml" indent="yes"/>
  <xsl:param name="languages"> 
    <de></de>
    <en>X</en>
    <es></es>
    <fr></fr>
    <it></it>
    <nl></nl>
  </xsl:param>
  <xsl:param name="outfiletemplate"/>
  
  <xsl:template match="name|title|subtitle|intro">
    <xsl:param name="targetLanguage"/>
    <xsl:copy>
      <xsl:call-template name="google">
        <xsl:with-param name="text"><xsl:value-of select="."/></xsl:with-param>
        <xsl:with-param name="targetLanguage">
          <xsl:value-of select="$targetLanguage"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="category|readingtype|subtitle[@translate='terminology']">
    <xsl:param name="targetLanguage"/>
    <xsl:copy>
      <xsl:call-template name="spreadsheet">
        <xsl:with-param name="text"><xsl:value-of select="."/></xsl:with-param>
        <xsl:with-param name="sourceLanguage">nl</xsl:with-param>
        <xsl:with-param name="targetLanguage">
          <xsl:value-of select="$targetLanguage"/>
        </xsl:with-param>
        <xsl:with-param name="csv">https://spreadsheets.google.com/pub?key=0Au659FdpCliwdDZCMUk1czY3Y2U5TjRDOWtkY1daTmc&amp;hl=nl&amp;single=true&amp;gid=0&amp;output=csv</xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="passage">
    <xsl:param name="targetLanguage"/>
    <xsl:copy>
      <xsl:call-template name="bible">
        <xsl:with-param name="bibleref"><xsl:value-of select="../passagereference"/></xsl:with-param>
        <xsl:with-param name="targetLanguage">
          <xsl:value-of select="$targetLanguage"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
