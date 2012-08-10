<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon">
  
  <xsl:output name="xml" method="xml" indent="yes"/>
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template name="cache">
    <xsl:param name="url" tunnel="yes"/>
    <xsl:param name="cachefolder" select="'file:///C:/temp'" tunnel="yes"/>
    <xsl:variable name="collection">
      <xsl:call-template name="collection"/>
    </xsl:variable>
    <xsl:variable name="file">
      <xsl:call-template name="file"/>
    </xsl:variable>
    <xsl:variable name="cache">
      <xsl:copy-of select="collection(iri-to-uri($collection))"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$cache/item[@url = $url]">
        <xsl:copy-of select="$cache/item[@url = $url]/*"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="result">
          <xsl:copy-of select="document($url)"/>
        </xsl:variable>
        <saxon:try>
          <xsl:result-document href="{$file}" format="xml">
            <item url="{$url}">
              <xsl:copy-of select="$result"/>
            </item>
          </xsl:result-document>
          <saxon:catch errors="*">
            <xsl:message>Error caught while trying to write to <xsl:value-of select="$url"
              /></xsl:message>
          </saxon:catch>
        </saxon:try>
        <xsl:copy-of select="$result"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="collection">
    <xsl:param name="url" tunnel="yes"/>
    <xsl:param name="cachefolder" tunnel="yes"/>
    <xsl:variable name="pcollection">$cachefolder/?select=$url.xml</xsl:variable>
    <xsl:call-template name="replace">
      <xsl:with-param name="encode" select="'no'"/>
      <xsl:with-param name="string" select="$pcollection"/>
      <xsl:with-param name="parametergroup">
        <cachefolder>
          <xsl:value-of select="$cachefolder"/>
        </cachefolder>
        <url>
          <xsl:value-of select="translate($url,'/','_')"/>
        </url>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="file">
    <xsl:param name="url" tunnel="yes"/>
    <xsl:param name="cachefolder" tunnel="yes"/>
    <xsl:variable name="pfile">$cachefolder/$url.xml</xsl:variable>
    <xsl:call-template name="replace">
      <xsl:with-param name="encode" select="'no'"/>
      <xsl:with-param name="string" select="$pfile"/>
      <xsl:with-param name="parametergroup">
        <cachefolder>
          <xsl:value-of select="$cachefolder"/>
        </cachefolder>
        <url>
          <xsl:value-of select="translate($url,'/','_')"/>
        </url>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="replace">
    <!-- copied from liturgical.calendar.build-ruleset.xslt and added encoding func -->
    <xsl:param name="string"/>
    <xsl:param name="parametergroup"/>
    <xsl:param name="encode" select="'no'"/>
    <xsl:choose>
      <xsl:when test="not(matches($string,'\$'))">
        <xsl:value-of select="$string"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="replacement">
          <xsl:choose>
            <xsl:when test="$encode = 'yes'">
              <xsl:value-of select="encode-for-uri($parametergroup/*[1])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$parametergroup/*[1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="replace"
          select="replace($string,concat('\$',local-name($parametergroup/*[1])),$replacement)"/>
        <xsl:call-template name="replace">
          <xsl:with-param name="string" select="$replace"/>
          <xsl:with-param name="parametergroup">
            <xsl:copy-of select="$parametergroup/*[position() &gt; 1]"/>
          </xsl:with-param>
          <xsl:with-param name="encode" select="$encode"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
