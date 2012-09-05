<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:foo="http://www.stackoverflow.com"
  xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon">

  <xsl:output name="xml" method="xml" indent="yes"/>
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:variable name="default-cachefolder" select="'file:///C:/temp'"/>

  <xsl:template name="cache">
    <xsl:param name="url" tunnel="yes"/>
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
        <xsl:choose>
           <xsl:when test="normalize-space($result) != ''">
              <saxon:try>
                <xsl:result-document href="{$file}" format="xml">
                  <item url="{$url}">
                    <xsl:copy-of select="$result"/>
                  </item>
                </xsl:result-document>
                <saxon:catch errors="*">
                  <xsl:message>Error caught while trying to write to <xsl:value-of select="$file"
                    /></xsl:message>
                </saxon:catch>
              </saxon:try>
           </xsl:when>
           <xsl:otherwise>
             <xsl:message>cache.xslt: REST call returned empty string, not storing in cache, but returning anyhow. URL = <xsl:value-of select="$url"/></xsl:message>
           </xsl:otherwise>
        </xsl:choose>
        <xsl:copy-of select="$result"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="collection">
    <xsl:param name="url" tunnel="yes"/>
    <xsl:param name="cachefolder" select="$default-cachefolder" tunnel="yes"/>
    <xsl:variable name="pcollection">$cachefolder/?select=$url.xml</xsl:variable>
    <xsl:call-template name="replace">
      <xsl:with-param name="encode" select="'no'"/>
      <xsl:with-param name="string" select="$pcollection"/>
      <xsl:with-param name="parametergroup">
        <cachefolder>
          <xsl:value-of select="$cachefolder"/>
        </cachefolder>
        <url>
          <xsl:value-of select="foo:checksum($url)"/>
        </url>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="file">
    <xsl:param name="url" tunnel="yes"/>
    <xsl:param name="cachefolder" select="$default-cachefolder" tunnel="yes"/>
    <xsl:variable name="pfile">$cachefolder/$url.xml</xsl:variable>
    <xsl:call-template name="replace">
      <xsl:with-param name="encode" select="'no'"/>
      <xsl:with-param name="string" select="$pfile"/>
      <xsl:with-param name="parametergroup">
        <cachefolder>
          <xsl:value-of select="$cachefolder"/>
        </cachefolder>
        <url>
          <xsl:value-of select="foo:checksum($url)"/>
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

  <!-- http://stackoverflow.com/questions/6753343/using-xsl-to-make-a-hash-of-xml-file -->
  <xsl:function name="foo:checksum" as="xs:integer">
    <xsl:param name="str" as="xs:string"/>
    <xsl:variable name="codepoints" select="string-to-codepoints($str)"/>
    <xsl:value-of select="foo:fletcher16($codepoints, count($codepoints), 1, 0, 0)"/>
  </xsl:function>
  <xsl:function name="foo:fletcher16">
    <xsl:param name="str" as="xs:integer*"/>
    <xsl:param name="len" as="xs:integer" />
    <xsl:param name="index" as="xs:integer" />
    <xsl:param name="sum1" as="xs:integer" />
    <xsl:param name="sum2" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$index ge $len">
        <xsl:sequence select="$sum2 * 256 + $sum1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="newSum1" as="xs:integer"
          select="($sum1 + $str[$index]) mod 255"/>
        <xsl:sequence select="foo:fletcher16($str, $len, $index + 1, $newSum1,
          ($sum2 + $newSum1) mod 255)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
