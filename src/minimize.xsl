<?xml version="1.0" encoding="UTF-8"?>
<!--
    used to remove unit tests etc and produce min code
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:unit="unittest"
    exclude-result-prefixes="unit"
    version="1.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xsl:template[substring(@name,1,4)='unit']"/>
    <xsl:template match="xsl:template[@match='/']"/>
    <xsl:template match="xsl:message"/>
    <xsl:template match="text()"><xsl:value-of select="normalize-space(.)"/></xsl:template>
</xsl:stylesheet>