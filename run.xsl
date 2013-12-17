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
        <xsl:variable name="NewJerseyUtcshiftInHours" select="6"/>
        <xsl:call-template name="date:date-time">
            <xsl:with-param name="utctimestampmilliseconds" select="1385409600000 + ($NewJerseyUtcshiftInHours*60*60*1000)"/>
            <xsl:with-param name="shifttzinminutes" select="0"/>
            <xsl:with-param name="is_include_milliseconds" select="false()"/>
        </xsl:call-template>
        <xsl:value-of select="2300 mod 1000"/>
        <xsl:text>&#x0A;</xsl:text>
        
        <!-- test1 begin -->
        <xsl:if test="true()">
            <xsl:variable name="name" select="'test1'"></xsl:variable>
            <xsl:variable name="expected" select="'2013-11-25T20:00:00Z'"/>
            <xsl:variable name="actual">
                <xsl:call-template name="date:date-time">
                    <xsl:with-param name="utctimestampmilliseconds" select="1385409600000"/>
                    <xsl:with-param name="is_include_milliseconds" select="false()"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$actual = $expected"><xsl:value-of select="$name"/> passed</xsl:when>
                <xsl:otherwise><xsl:value-of select="$name"/> not passed, was:<xsl:value-of select="$actual"/> expected: <xsl:value-of select="$expected"/></xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:if>
        <!-- test1 end -->
        
        <!-- test1Milliseconds begin -->
        <xsl:if test="true()">
            <xsl:variable name="name" select="'test1Milliseconds'"></xsl:variable>
            <xsl:variable name="expected" select="'2013-11-25T20:00:00.001Z'"/>
            <xsl:variable name="actual">
                <xsl:call-template name="date:date-time">
                    <xsl:with-param name="utctimestampmilliseconds" select="1385409600001"/>
                    <xsl:with-param name="is_include_milliseconds" select="true()"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$actual = $expected"><xsl:value-of select="$name"/> passed</xsl:when>
                <xsl:otherwise><xsl:value-of select="$name"/> not passed, was:<xsl:value-of select="$actual"/> expected: <xsl:value-of select="$expected"/></xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:if>
        <!-- test1Milliseconds end -->
        
        <!-- test2 begin -->
        <xsl:if test="true()">
            <xsl:variable name="name" select="'test2'"></xsl:variable>
            <xsl:variable name="expected" select="'2013-12-26T03:44:00Z'"/>
            <xsl:variable name="actual">
                <xsl:call-template name="date:date-time">
                    <xsl:with-param name="utctimestampmilliseconds" select="1388029440000"/>
                    <xsl:with-param name="is_include_milliseconds" select="false()"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="$actual = $expected"><xsl:value-of select="$name"/> passed</xsl:when>
                <xsl:otherwise><xsl:value-of select="$name"/> not passed, was:<xsl:value-of select="$actual"/> expected: <xsl:value-of select="$expected"/></xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:if>
        <!-- test2 end -->
        
        <!-- test2shift begin -->
        <xsl:if test="true()">
            <xsl:variable name="name" select="'test2'"></xsl:variable>
            <xsl:variable name="expected" select="'2013-12-26T04:44:00+01:00'"/>
            <xsl:variable name="actual">
                <xsl:call-template name="date:date-time">
                    <xsl:with-param name="utctimestampmilliseconds" select="1388029440000"/>
                    <xsl:with-param name="shifttzinminutes" select="60"></xsl:with-param>
                    <xsl:with-param name="is_include_milliseconds" select="false()"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="$actual = $expected"><xsl:value-of select="$name"/> passed</xsl:when>
                <xsl:otherwise><xsl:value-of select="$name"/> not passed, was:<xsl:value-of select="$actual"/> expected: <xsl:value-of select="$expected"/></xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:if>
        <!-- test2shift end -->
        
        <!-- testPadding begin -->
        <xsl:if test="true()">
            <xsl:variable name="name" select="'testPadding'"></xsl:variable>
            <xsl:variable name="expected" select="'2013-06-05T18:46:40+01:00'"/>
            <xsl:variable name="actual">
                <xsl:call-template name="date:date-time">
                    <xsl:with-param name="utctimestampmilliseconds" select="1370454400000"/>
                    <xsl:with-param name="shifttzinminutes" select="60"></xsl:with-param>
                    <xsl:with-param name="is_include_milliseconds" select="false()"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="$actual = $expected"><xsl:value-of select="$name"/> passed</xsl:when>
                <xsl:otherwise><xsl:value-of select="$name"/> not passed, was:<xsl:value-of select="$actual"/> expected: <xsl:value-of select="$expected"/></xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:if>
        <!-- testPadding end -->
        
    </xsl:template>
</xsl:stylesheet>