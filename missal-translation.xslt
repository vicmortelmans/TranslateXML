<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="yql_translation.xslt"/>
	<xsl:output method="xml" indent="yes"/>
  <xsl:param name="languages"> 
    <de>X</de>
    <en>X</en>
    <es>X</es>
    <fr>X</fr>
    <it>X</it>
    <nl>X</nl>
  </xsl:param>
  <xsl:param name="outfiletemplate"/>
  <xsl:template match="name">
     <xsl:param name="language"/>
     <xsl:call-template name="yql">
         <xsl:with-param name="query">
            <xsl:call-template name="replace">
               <xsl:with-param name="string">
                   select * from google.translate where q="$text" and target="$language"
               </xsl:with-param>
               <xsl:with-param name="parameters">
                 <text>
                     <xsl:value-of select="."/>
                 </text>
                 <language>
                     <xsl:value-of select="$language"/>
                 </language>
               </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
