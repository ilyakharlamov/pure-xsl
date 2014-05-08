<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" xmlns:unit="unittest" xmlns:pxml="https://github.com/ilyakharlamov/pure-xsl/parseStringAsXML" exclude-result-prefixes="exslt unit" version="1.0">
   <xsl:output method="xml" indent="yes"/>
   <xsl:template name="pxml:parseContent">
      <xsl:param name="escaped"/>
      <xsl:variable name="length" select="string-length($escaped)"/>
      <xsl:if test="$length &gt; 0">
         <xsl:variable name="elementname">
            <xsl:call-template name="getElementName">
               <xsl:with-param name="text" select="$escaped"/>
            </xsl:call-template>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="string-length($elementname)"><!-- element -->
               <xsl:variable name="tagcontent">
                  <xsl:call-template name="getTagContent">
                     <xsl:with-param name="text" select="$escaped"/>
                  </xsl:call-template>
               </xsl:variable>
               <xsl:variable name="isShort" select="substring($tagcontent,string-length($tagcontent),1)='/'"/>
               <xsl:element name="{$elementname}">
                  <xsl:call-template name="parseAttributes">
                     <xsl:with-param name="tagcontent" select="substring-after($tagcontent,$elementname)"/>
                  </xsl:call-template>
                  <xsl:call-template name="pxml:parseContent">
                     <xsl:with-param name="escaped">
                        <xsl:if test="not($isShort)">
                           <xsl:value-of select="substring-before(substring-after($escaped,'&gt;'),concat('&lt;/',$elementname))"/>
                        </xsl:if>
                     </xsl:with-param>
                  </xsl:call-template>
               </xsl:element>
               <xsl:call-template name="pxml:parseContent">
                  <xsl:with-param name="escaped">
                     <xsl:choose>
                        <xsl:when test="$isShort">
                           <xsl:value-of select="substring-after($escaped,'&gt;')"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="substring-after(substring-after($escaped,concat('&lt;/',$elementname)),'&gt;')"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:with-param>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise><!-- text -->
               <xsl:variable name="ltposition" select="string-length(substring-before($escaped,'&lt;'))"/>
               <xsl:call-template name="replaceAmp">
                  <xsl:with-param name="text">
                     <xsl:choose>
                        <xsl:when test="$ltposition=0">
                           <xsl:value-of select="$escaped"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="substring($escaped,1,$ltposition)"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:with-param>
               </xsl:call-template>
               <xsl:if test="$ltposition">
                  <xsl:call-template name="pxml:parseContent">
                     <xsl:with-param name="escaped" select="substring($escaped,$ltposition+1)"/>
                  </xsl:call-template>
               </xsl:if>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <xsl:template name="replaceAmp">
      <xsl:param name="text"/>
      <xsl:choose>
         <xsl:when test="contains($text,'&amp;')">
            <xsl:variable name="abbr" select="substring-before(substring-after($text,'&amp;'),';')"/>
            <xsl:value-of select="substring-before($text,'&amp;')"/>
            <xsl:choose>
               <xsl:when test="$abbr='lt'">&lt;</xsl:when>
               <xsl:when test="$abbr='gt'">&gt;</xsl:when>
               <xsl:when test="$abbr='quot'">"</xsl:when>
               <xsl:when test="$abbr='apos'">'</xsl:when>
               <xsl:when test="$abbr='amp'">&amp;</xsl:when>
            </xsl:choose>
            <xsl:value-of select="substring-after($text,';')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$text"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="parseAttributes">
      <xsl:param name="tagcontent"/>
      <xsl:if test="string-length(translate($tagcontent,'/',''))">
         <xsl:choose>
            <xsl:when test="substring($tagcontent,1,1)=' '">
               <xsl:call-template name="parseAttributes">
                  <xsl:with-param name="tagcontent" select="substring($tagcontent,2)"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:variable name="vacuumed" select="translate($tagcontent,' ','')"/>
               <xsl:variable name="attrname" select="substring-before($vacuumed,'=')"/>
               <xsl:variable name="quot" select="substring(substring-after($vacuumed, '='),1,1)"/>
               <xsl:variable name="content" select="substring-before(substring-after($tagcontent,$quot),$quot)"/>
               <xsl:attribute name="{$attrname}">
                  <xsl:value-of select="$content"/>
               </xsl:attribute>
               <xsl:call-template name="parseAttributes">
                  <xsl:with-param name="tagcontent" select="substring-after(substring-after($tagcontent,$quot),$quot)"/>
               </xsl:call-template>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <xsl:template name="getTagContent">
      <xsl:param name="text"/>
      <xsl:value-of select="substring-before(substring($text,2),'&gt;')"/>
   </xsl:template>
   <xsl:template name="getElementName">
      <xsl:param name="text"/>
      <xsl:variable name="tagcontents">
         <xsl:call-template name="getTagContent">
            <xsl:with-param name="text" select="$text"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="contains($tagcontents, ' ')">
            <xsl:value-of select="substring-before($tagcontents,' ')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="substring($tagcontents, string-length($tagcontents),'1')='/'">
                  <xsl:value-of select="substring-before($tagcontents,'/')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$tagcontents"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>