<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
  
  <xsl:template match="/">
    <xsl:variable name="input" select="*"/>
    <xsl:for-each select="$languages/*[normalize-space(.)]">
      <xsl:variable name="outfile" select="replace($outfiletemplate,'\$language',name(.))"/>
      <xsl:result-document href="{$outfile}" method="xml">
        <xsl:apply-templates select="$input">
          <xsl:with-param name="targetLanguage" select="name(.)"/>
        </xsl:apply-templates>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="map|task|concept">
    <xsl:param name="targetLanguage"/>
    <xsl:copy>
      <xsl:attribute name="xml:lang"><xsl:value-of select="$targetLanguage"/></xsl:attribute>
      <xsl:apply-templates  select="@*|node()">
        <xsl:with-param name="targetLanguage" select="$targetLanguage"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:param name="targetLanguage"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="targetLanguage" select="$targetLanguage"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- LIBRARY OF TRANSLATION TOOLS -->
  
  <xsl:template name="spreadsheet">
    <xsl:param name="text"/>
    <xsl:param name="sourceLanguage"/>
    <xsl:param name="targetLanguage"/>
    <xsl:param name="csv"/>
    <xsl:attribute name="xml:lang"><xsl:value-of select="$targetLanguage"/></xsl:attribute>
    <xsl:call-template name="yql">
        <xsl:with-param name="query">
           <xsl:call-template name="replace">
              <xsl:with-param name="string">
                  <xsl:text>select * from xml where itemPath = "/query/results/row/*[../*[name(.) = name(../../row[1]/*[. = '$sourceLanguage'])] = '$text' and name(.) = name(../../row[1]/*[. = '$targetLanguage'])]" and  url = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20csv%20where%20url%3D%22$csvencoded%22&amp;diagnostics=false"</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="parameters">
                <text><xsl:value-of select="$text"/></text>
                <sourceLanguage><xsl:value-of select="$sourceLanguage"/></sourceLanguage>
                <targetLanguage><xsl:value-of select="$targetLanguage"/></targetLanguage>
                <csvencoded><xsl:value-of select="encode-for-uri($csv)"/></csvencoded>
              </xsl:with-param>
           </xsl:call-template>
       </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="bible">
    <xsl:param name="targetLanguage"/>
    <xsl:param name="bibleref"/>
    <xsl:attribute name="xml:lang"><xsl:value-of select="$targetLanguage"/></xsl:attribute>
    <xsl:call-template name="yql">
        <xsl:with-param name="query">
           <xsl:call-template name="replace">
              <xsl:with-param name="string">
                  <xsl:text>use "http://github.com/vicmortelmans/yql-tables/raw/master/bible/bible.xml" as bible.bible;</xsl:text>
                  <xsl:text>select * from bible.bible where bibleref='$bibleref' and language='$targetLanguage'</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="parameters">
                <bibleref><xsl:value-of select="$bibleref"/></bibleref>
                <targetLanguage><xsl:value-of select="$targetLanguage"/></targetLanguage>
              </xsl:with-param>
           </xsl:call-template>
       </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="xml">
    <xsl:param name="text"/>
    <xsl:param name="sourceLanguage"/>
    <xsl:param name="targetLanguage"/>
    <xsl:param name="url"/>
    <xsl:param name="language"/>
    <xsl:attribute name="xml:lang"><xsl:value-of select="$targetLanguage"/></xsl:attribute>
    <xsl:call-template name="yql">
        <xsl:with-param name="query">
           <xsl:call-template name="replace">
              <xsl:with-param name="string">
                <xsl:text>select * from xml where url="$url" and itemPath="//input[@language='$targetLanguage' and ../input[@language='$sourceLanguage']='$text']"</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="parameters">
                <text><xsl:value-of select="$text"/></text>
                <sourceLanguage><xsl:value-of select="$sourceLanguage"/></sourceLanguage>
                <targetLanguage><xsl:value-of select="$targetLanguage"/></targetLanguage>
                <url><xsl:value-of select="$url"/></url>
              </xsl:with-param>
           </xsl:call-template>
       </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="google">
    <xsl:param name="text"/>
    <xsl:param name="targetLanguage"/>
    <xsl:attribute name="xml:lang"><xsl:value-of select="$targetLanguage"/></xsl:attribute>
    <xsl:call-template name="yql">
        <xsl:with-param name="query">
           <xsl:call-template name="replace">
              <xsl:with-param name="string">
                <xsl:text>use "http://www.datatables.org/google/google.translate.xml" as google.translate;</xsl:text>
                <xsl:text>select * from google.translate where q="$text" and target="$targetLanguage"</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="parameters">
                <text>
                    <xsl:value-of select="."/>
                </text>
                <targetLanguage>
                    <xsl:value-of select="$targetLanguage"/>
                </targetLanguage>
              </xsl:with-param>
           </xsl:call-template>
       </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- UTILITY TEMPLATES -->

  <xsl:template name="yql">
    <xsl:param name="query"/>
    <!-- query.yahooapis.com -->
    <xsl:variable name="rest" select="concat('http://query.yahooapis.com/v1/public/yql','?q=',encode-for-uri($query))"/>
    <xsl:variable name="results" select="document($rest)/query/results"/>
    <!--xsl:apply-templates select="$results"/-->
    <xsl:value-of select="$results"/>
  </xsl:template>

  <xsl:template name="replace">
   <xsl:param name="string"/>
   <xsl:param name="parameters"/>
   <xsl:choose>
     <xsl:when test="count($parameters/*) &gt; 0">
       <xsl:variable name="string2">
          <xsl:value-of select="replace($string,concat('\$',name($parameters/*[1])),normalize-space($parameters/*[1]))"/>
       </xsl:variable>
       <xsl:call-template name="replace">
         <xsl:with-param name="string" select="$string2"/>
         <xsl:with-param name="parameters">
          <xsl:copy-of select="$parameters/*[position() &gt; 1]"/>
         </xsl:with-param>
       </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$string"/>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  
</xsl:stylesheet>
