<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="https://github.com/ilyakharlamov/pure-xsl/date"
    version="1.0">
    <xsl:import href="date.xsl"/>
    <xsl:template match="/">
        <xsl:text>converted back:</xsl:text>
        <xsl:call-template name="date:timestamp">
            <xsl:with-param name="date-time" select="'2013-09-05T00:00:00+02:00'"/>
        </xsl:call-template>
        <xsl:text>
            
        </xsl:text>
        
        <xsl:call-template name="date:date-time">
            <xsl:with-param name="utctimestamp" select="1385409600000"/>
            <xsl:with-param name="shifttzinminutes" select="240"/>
            <xsl:with-param name="is_include_milliseconds" select="false()"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>