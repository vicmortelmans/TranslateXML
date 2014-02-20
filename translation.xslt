<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="cache.xslt"/>

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="@*|node()" mode="translation">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="translation"/>
    </xsl:copy>
  </xsl:template>

  <!-- LIBRARY OF TRANSLATION TOOLS -->

  <xsl:template name="spreadsheet">
    <xsl:param name="text"/>
    <xsl:param name="sourceLanguage"/>
    <xsl:param name="targetLanguage"/>
    <xsl:param name="csv"/>
    <!--xsl:attribute name="xml:lang"><xsl:value-of select="$targetLanguage"/></xsl:attribute-->
    <xsl:call-template name="yql">
      <xsl:with-param name="query">
        <xsl:call-template name="replace">
          <xsl:with-param name="string">
            <xsl:text>select * from xml where itemPath = "/query/results/row[*[name(.) = name(../../row[1]/*[. = '$sourceLanguage'])] = '$text'][1]/*[name(.) = name(../../row[1]/*[. = '$targetLanguage'])]" and  url = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20csv%20where%20url%3D%22$csvencoded%22&amp;diagnostics=false"</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="parametergroup">
            <text>
              <xsl:value-of select="$text"/>
            </text>
            <sourceLanguage>
              <xsl:value-of select="$sourceLanguage"/>
            </sourceLanguage>
            <targetLanguage>
              <xsl:value-of select="$targetLanguage"/>
            </targetLanguage>
            <csvencoded>
              <xsl:value-of select="encode-for-uri($csv)"/>
            </csvencoded>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="bibleref">
    <xsl:param name="targetLanguage"/>
    <xsl:param name="bibleref"/>
    <xsl:variable name="locbibleref">
      <xsl:call-template name="yql-xml">
        <xsl:with-param name="query">
          <xsl:call-template name="replace">
            <xsl:with-param name="string">
              <xsl:text>use 'http://github.com/vicmortelmans/yql-tables/raw/master/bible/bibleref.xml' as bible.bibleref;</xsl:text>
              <xsl:text>select * from bible.bibleref where bibleref='$bibleref' and language='$language'</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="parametergroup">
              <bibleref>
                <xsl:value-of select="$bibleref"/>
              </bibleref>
              <language>
                <xsl:value-of select="$targetLanguage"/>
              </language>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$locbibleref//bibleref[1]/localbook"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$locbibleref//bibleref[1]/chapterversereference"/>
  </xsl:template>
  
  <xsl:template name="bible">
    <xsl:param name="targetLanguage"/>
    <xsl:param name="bibleref"/>
    <!--xsl:attribute name="xml:lang"><xsl:value-of select="$targetLanguage"/></xsl:attribute-->
    <xsl:call-template name="yql">
      <xsl:with-param name="query">
        <xsl:call-template name="replace">
          <xsl:with-param name="string">
            <xsl:text>use "https://raw.github.com/vicmortelmans/yql-tables/master/bible/bible.bible.xml" as bible.bible;</xsl:text>
            <xsl:text>select * from bible.bible where bibleref='$bibleref' and language='$targetLanguage'</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="parametergroup">
            <bibleref>
              <xsl:value-of select="$bibleref"/>
            </bibleref>
            <targetLanguage>
              <xsl:value-of select="$targetLanguage"/>
            </targetLanguage>
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
    <!--xsl:attribute name="xml:lang"><xsl:value-of select="$targetLanguage"/></xsl:attribute-->
    <xsl:call-template name="yql">
      <xsl:with-param name="query">
        <xsl:call-template name="replace">
          <xsl:with-param name="string">
            <xsl:text>select * from xml where url="$url" and itemPath="//input[@language='$targetLanguage' and ../input[@language='$sourceLanguage']='$text']"</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="parametergroup">
            <text>
              <xsl:value-of select="$text"/>
            </text>
            <sourceLanguage>
              <xsl:value-of select="$sourceLanguage"/>
            </sourceLanguage>
            <targetLanguage>
              <xsl:value-of select="$targetLanguage"/>
            </targetLanguage>
            <url>
              <xsl:value-of select="$url"/>
            </url>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="google">
    <xsl:param name="text"/>
    <xsl:param name="targetLanguage"/>
    <!--xsl:attribute name="xml:lang"><xsl:value-of select="$targetLanguage"/></xsl:attribute-->
    <xsl:call-template name="yql">
      <xsl:with-param name="query">
        <xsl:call-template name="replace">
          <xsl:with-param name="string">
            <xsl:text>use "http://www.datatables.org/google/google.translate.xml" as google.translate;</xsl:text>
            <xsl:text>select * from google.translate where q="$text" and target="$targetLanguage"</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="parametergroup">
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
    <xsl:variable name="result">
      <xsl:call-template name="yql-xml">
        <xsl:with-param name="query" select="$query"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$result"/>
  </xsl:template>
  
  <xsl:template name="yql-xml">
    <xsl:param name="query"/>
    <xsl:param name="cache" select="'yes'" tunnel="yes"/>
    <!--xsl:message>YQL <xsl:value-of select="$query"/></xsl:message-->
    <!-- query.yahooapis.com -->
    <xsl:variable name="rest"
      select="concat('http://query.yahooapis.com/v1/public/yql','?q=',encode-for-uri($query))"/>
    <xsl:variable name="results">
      <xsl:choose>
        <xsl:when test="$cache = 'yes'">
          <xsl:call-template name="cache">
            <xsl:with-param name="url" select="$rest" tunnel="yes"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="rest-with-diagnostics" select="concat($rest,'&amp;diagnostics=true')"/>
          <xsl:variable name="restcontent">
            <xsl:message>Fetching data from YQL [<xsl:value-of select="$rest-with-diagnostics"/>]</xsl:message>
            <xsl:copy-of select="document($rest-with-diagnostics)"/>
          </xsl:variable>
          <xsl:variable name="results" select="$restcontent/query/results"/>
          <xsl:if test="normalize-space($results) = ''">
            <xsl:message>translation.xslt template yql-xml query returned no results - <xsl:value-of select="$query"/> - <xsl:copy-of select="$restcontent/query/diagnostics"/></xsl:message>
          </xsl:if>
          <xsl:copy-of select="$results"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--xsl:apply-templates select="$results"/-->
    <xsl:copy-of select="$results"/>
  </xsl:template>
  
</xsl:stylesheet>
