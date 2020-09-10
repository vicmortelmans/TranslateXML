<?xml version="1.0"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="translation.xslt"/>
  <xsl:variable name="newline" select="'&#10;'"/>
  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="/">
    <bibleref>
      <xsl:call-template name="bibleref">
        <xsl:with-param name="targetLanguage">nl</xsl:with-param>
        <xsl:with-param name="bibleref">II John I,2</xsl:with-param>
      </xsl:call-template>
    </bibleref>
    <bible>
      <xsl:call-template name="bible">
        <xsl:with-param name="targetLanguage">nl</xsl:with-param>
        <xsl:with-param name="bibleref">II John I,2</xsl:with-param>
      </xsl:call-template>
    </bible>
    <spreadsheet-gewone-gebeden>
      <xsl:call-template name="spreadsheet">
        <xsl:with-param name="text">Asperges me</xsl:with-param>
        <xsl:with-param name="sourceLanguage">la</xsl:with-param>
        <xsl:with-param name="targetLanguage">nl</xsl:with-param>
        <xsl:with-param name="csv">Gewone Gebeden van de Mis - local names.xml</xsl:with-param>
      </xsl:call-template>
    </spreadsheet-gewone-gebeden>
  </xsl:template>
</xsl:stylesheet>

