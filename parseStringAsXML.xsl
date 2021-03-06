<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" xmlns:unit="unittest" xmlns:pxml="https://github.com/ilyakharlamov/pure-xsl/parseStringAsXML" xmlns:local="https://github.com/ilyakharlamov/pure-xsl/parseStringAsXML/local" exclude-result-prefixes="exslt unit pxml" version="1.0">
   <xsl:output method="xml" indent="yes"/>
   <xsl:template name="pxml:parseStringAsXML">
      <xsl:param name="string"/>
      <xsl:call-template name="local:parseStringAsXML">
         <xsl:with-param name="remaining" select="$string"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="local:parseStringAsXML">
      <xsl:param name="remaining"/>
      <xsl:param name="stack"/>
      <xsl:param name="out"/>
      <xsl:param name="counter" select="0"/>
      <xsl:choose>
         <xsl:when test="string-length($remaining)">
            <xsl:variable name="event">
               <xsl:choose>
                  <xsl:when test="starts-with($remaining,'&lt;/')">endElement</xsl:when>
                  <xsl:when test="starts-with($remaining,'&lt;')">startElement</xsl:when>
                  <xsl:otherwise>characters</xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="current">
               <xsl:choose>
                  <xsl:when test="contains($event,'Element')">
                     <xsl:value-of select="concat(substring-before($remaining,'&gt;'), '&gt;')"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="substring-before($remaining,'&lt;')"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="tagcontents" select="substring-after(substring-before($remaining,'&gt;'), '&lt;')"/>
            <xsl:variable name="elementname">
               <xsl:call-template name="local:getElementName">
                  <xsl:with-param name="tagcontents" select="$tagcontents"/>
               </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="currentElement">
               <xsl:choose>
                  <xsl:when test="$event='startElement'">
                     <xsl:element name="{$elementname}">
                        <xsl:call-template name="local:parseAttributes">
                           <xsl:with-param name="tagcontent" select="substring-after($tagcontents,$elementname)"/>
                        </xsl:call-template>
                     </xsl:element>
                  </xsl:when>
                  <xsl:when test="$event='characters'">
                     <xsl:call-template name="local:replaceAmp">
                        <xsl:with-param name="text" select="$current"/>
                     </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="substring-before($remaining,'&lt;')"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="emptyElementNormalization">
               <xsl:if test="substring($current,string-length($current) - 1)='/&gt;'">
                  <xsl:value-of select="concat('&lt;/',$elementname,'&gt;')"/>
               </xsl:if>
            </xsl:variable>
            <xsl:variable name="newstack">
               <xsl:choose>
                  <xsl:when test="$event='startElement'">
                     <xsl:value-of select="concat($stack,$current)"/>
                  </xsl:when>
                  <xsl:when test="$event='endElement'">
                     <xsl:call-template name="local:substring-before-last">
                        <xsl:with-param name="where" select="$stack"/>
                        <xsl:with-param name="what" select="'&lt;'"/>
                     </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$stack"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="newout">
               <xsl:choose>
                  <xsl:when test="$event='startElement' or $event='characters'">
                     <xsl:call-template name="local:inject">
                        <xsl:with-param name="out" select="$out"/>
                        <xsl:with-param name="stack" select="$stack"/>
                        <xsl:with-param name="data">
                           <xsl:copy-of select="$currentElement"/>
                        </xsl:with-param>
                     </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:copy-of select="$out"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="local:parseStringAsXML">
               <xsl:with-param name="stack" select="$newstack"/>
               <xsl:with-param name="out">
                  <xsl:copy-of select="$newout"/>
               </xsl:with-param>
               <xsl:with-param name="remaining" select="concat($emptyElementNormalization, substring($remaining, string-length($current)+1))"/>
               <xsl:with-param name="counter" select="$counter + 1"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="$out"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="local:inject">
      <xsl:param name="stack"/>
      <xsl:param name="out"/>
      <xsl:param name="data"/>
      <xsl:choose>
         <xsl:when test="string-length($stack)">
            <xsl:variable name="current" select="concat(substring-before($stack,'&gt;'),'&gt;')"/>
            <xsl:variable name="currentElementName">
               <xsl:call-template name="local:getElementName">
                  <xsl:with-param name="tagcontents" select="substring-after(substring-before($current,'&gt;'),'&lt;')"/>
               </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="exslt:node-set($out)/node()">
               <xsl:copy>
                  <xsl:choose>
                     <xsl:when test="name()=$currentElementName">
                        <xsl:copy-of select="@*|text()|comment()"/>
                        <xsl:call-template name="local:inject">
                           <xsl:with-param name="stack" select="substring($stack, string-length($current)+1)"/>
                           <xsl:with-param name="data" select="$data"/>
                           <xsl:with-param name="out">
                              <xsl:for-each select="exslt:node-set($out)/*[name() = $currentElementName]/*">
                                 <xsl:copy>
                                    <xsl:copy-of select="node()|@*"/>
                                 </xsl:copy>
                              </xsl:for-each>
                           </xsl:with-param>
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:copy-of select="node()|@*"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:copy>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="$out"/>
            <xsl:copy-of select="$data"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="local:replaceAmp">
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
   <xsl:template name="local:parseAttributes">
      <xsl:param name="tagcontent"/>
      <xsl:if test="string-length(translate($tagcontent,'/',''))">
         <xsl:choose>
            <xsl:when test="substring($tagcontent,1,1)=' '">
               <xsl:call-template name="local:parseAttributes">
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
               <xsl:call-template name="local:parseAttributes">
                  <xsl:with-param name="tagcontent" select="substring-after(substring-after($tagcontent,$quot),$quot)"/>
               </xsl:call-template>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <xsl:template name="local:getElementName">
      <xsl:param name="tagcontents"/>
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
   <xsl:template name="local:substring-before-last">
      <xsl:param name="where" select="''"/>
      <xsl:param name="what" select="''"/>
      <xsl:if test="$where != '' and $what != ''">
         <xsl:variable name="head" select="substring-before($where, $what)"/>
         <xsl:variable name="tail" select="substring-after($where, $what)"/>
         <xsl:value-of select="$head"/>
         <xsl:if test="contains($tail, $what)">
            <xsl:value-of select="$what"/>
            <xsl:call-template name="local:substring-before-last">
               <xsl:with-param name="where" select="$tail"/>
               <xsl:with-param name="what" select="$what"/>
            </xsl:call-template>
         </xsl:if>
      </xsl:if>
   </xsl:template>
</xsl:stylesheet>