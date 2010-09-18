<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
  <xsl:template match="/">
    <xsl:variable name="input" select="*"/>
    <xsl:for-each select="$languages/*[normalize-space(.)]">
      <xsl:variable name="outfile" select="replace($outfiletemplate,'\$language',name(.))"/>
      <xsl:result-document href="{$outfile}" method="xml">
        <xsl:apply-templates select="$input">
          <xsl:with-param name="language" select="name(.)"/>
        </xsl:apply-templates>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="*">
    <xsl:param name="language"/>
    <xsl:apply-templates>
      <xsl:with-param name="language" select="$language"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template name="yql">
    <xsl:param name="query"/>
    <!-- query.yahooapis.com -->
    <xsl:variable name="rest" select="concat('http://69.147.126.237/v1/public/yql','?q=',encode-for-uri($query))"/>
    <xsl:apply-templates select="document($rest)/results"/>
  </xsl:template>
  <xsl:template name="replace">
   <xsl:param name="string"/>
   <xsl:param name="parameters"/>
   <xsl:choose>
     <xsl:when test="count($parameters) &gt; 0">
       <xsl:variable name="string2">
          <xsl:value-of select="replace($string,concat('\$',name($parameters/*[1])),normalize-space($parameters/*[1]))"/>
       </xsl:variable>
       <xsl:call-template name="replace">
         <xsl:with-param name="string" select="$string2"/>
         <xsl:with-param name="parameters" select="$parameters/*[position() &gt; 1]"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
        <xsl:message><xsl:value-of select="$string"/></xsl:message>
       <xsl:value-of select="$string"/>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
