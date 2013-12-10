<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="https://github.com/ilyakharlamov/pure-xsl/date"
    version="1.0">
    <xsl:output method="text"/>
    <xsl:decimal-format NaN="0"/>
    <xsl:template match="/">
        <xsl:variable name="time_as_timestamp" select="1365599995640"/>
        <xsl:text>time_as_timestamp:</xsl:text><xsl:value-of select="$time_as_timestamp"/><xsl:text>&#x0A;</xsl:text>
        <xsl:variable name="time_as_xsdatetime">
            <xsl:call-template name="date:date-time">
                <xsl:with-param name="timestamp" select="$time_as_timestamp"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>time_as_xsdatetime:</xsl:text><xsl:value-of select="$time_as_xsdatetime"/><xsl:text>&#x0A;</xsl:text>
        <xsl:text>back_as_timestamp:</xsl:text>
        <xsl:call-template name="date:timestamp">
            <xsl:with-param name="date-time" select="$time_as_xsdatetime"/>
        </xsl:call-template>
    </xsl:template>
    
    <date:month>
        <january>31</january>
        <february>28</february>
        <march>31</march>
        <april>30</april>
        <may>31</may>
        <june>30</june>
        <july>31</july>
        <august>31</august>
        <september>30</september>
        <october>31</october>
        <november>30</november>
        <december>31</december>
    </date:month>
    <xsl:variable name="date:month"
        select="document('')//date:month"/>
    
    
    <xsl:template name="date:timestamp">
        <xsl:param name="date-time"/>
       
        <xsl:variable name="compact"
            select="
            normalize-space(
            translate($date-time,'TZ ',''))"/>
        <xsl:variable name="year"
            select="
            translate(
            substring($compact,1,
            4+(starts-with($compact,'+') or
            starts-with($compact,'-'))),
            '+','')"/>
        <xsl:variable name="date"
            select="substring-after($compact,$year)"/>
        <xsl:variable name="time"
            select="substring($date,7)"/>
        <xsl:variable name="month"
            select="format-number(substring($date,2,2)-1,0)"/>
        <xsl:variable name="utc-offset">
            <xsl:variable name="raw"
                select="
                concat(
                substring-after($time,'+'),
                substring-after($time,'-'))"/>
            <xsl:value-of select="
                format-number(
                (contains($time,'-')-.5)
                *2*(substring($raw,1,2)*60
                +substring($raw,4,2)),0)"/>
        </xsl:variable>
        <xsl:value-of select="
            format-number(
            1000*(
            24*3600*(
            $year*365-719527
            +floor($year div 4)
            -floor($year div 100)
            +floor($year div 400)
            +sum($date:month/*[$month>=position()])
            +format-number(substring($date,5,2)-1,0)
            -(2>$month and (($year mod 4=0 and
            $year mod 100!=0) or
            $year mod 400=0)))
            +format-number(
            concat(0,substring($time,7,
            (substring($time,6,1)=':')*2))
            +substring($time,1,2)*3600
            +substring($time,4,2)*60,0)
            +$utc-offset*60)
            +format-number(
            round(
            (substring($time,9,1)='.')
            *1000*substring-before(
            translate(
            concat('0.',substring-after($time,'.'),'_'),
            '+-','__'),'_')),0),0)"/>
    </xsl:template>
    <xsl:template name="date:date-time">
        <xsl:param name="utctimestampmilliseconds"/><!-- UTC -->
        <xsl:param name="shifttzinminutes" select="0"/>
        <xsl:param name="is_include_milliseconds" select="true()"/>
        <xsl:variable name="utctimestampseconds" select="$utctimestampmilliseconds div 1000 + $shifttzinminutes*60"/>
        <xsl:variable name="s" select="$utctimestampseconds mod 86400"></xsl:variable>
        <xsl:variable name="h" select="floor($s div 3600)"></xsl:variable>
        <xsl:variable name="m" select="floor($s div 60 mod 60)"></xsl:variable>
        <xsl:variable name="seconds" select="floor($s mod 60)"/>
        <xsl:variable name="ts" select="floor($utctimestampseconds div 86400)"/>
        <xsl:variable name="x" select="floor(($ts*4+102032) div 146097+15)"></xsl:variable>
        <xsl:variable name="b" select="floor(($x div -4)+$ts+2442113+$x)"/>
        <xsl:variable name="c" select="floor(($b*20 - 2442) div 7305)"/>
        <xsl:variable name="d" select="ceiling(($b) - (365*$c) - ($c div 4))"/>
        <xsl:variable name="e" select="floor($d*(1000 div 30601))"/>
        <xsl:variable name="f" select="ceiling($d - ($e*30) - ($e*601 div 1000))"/>
        
        <!--xsl:value-of select="concat('utctimestampseconds', $utctimestampseconds,' ts', $ts, ' x', $x, ' b', $b,' c',$c,' d', $d,' e', $e,' f', $f,' s:',$s,'h:',$h,'m:',$m,'seconds', $seconds)"/>
        <xsl:text>&#x0A;</xsl:text-->
        
        <xsl:variable name="timezonepart">
            <xsl:choose>
                <xsl:when test="$shifttzinminutes">
                    <xsl:variable name="shifttzsign">
                        <xsl:choose>
                            <xsl:when test="$shifttzinminutes > 0">
                                <xsl:value-of select="'+'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'-'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="shifttzhrsabs">
                        <xsl:variable name="vNum" select="$shifttzinminutes div 60"/>
                        <xsl:value-of select="$vNum*($vNum >=0) - $vNum*($vNum &lt; 0)"/>
                    </xsl:variable>
                    <xsl:variable name="shifttzminabs"><!-- abs number of minues -->
                        <xsl:variable name="vNum" select="$shifttzinminutes mod 60"/>
                        <xsl:value-of select="$vNum*($vNum >=0) - $vNum*($vNum &lt; 0)"/>
                    </xsl:variable>
                    <xsl:value-of select="concat($shifttzsign,format-number($shifttzhrsabs, '00'),':',format-number($shifttzminabs, '00'))"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="'Z'"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose><!-- YEAR-MO -->
            <xsl:when test="$e &lt; 14">
                <xsl:value-of select="$c - 4716"/>
                <xsl:value-of select="'-'"/>
                <xsl:value-of select="$e - 1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$c - 4715"/>
                <xsl:value-of select="'-'"/>
                <xsl:value-of select="$e - 13"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$f"/>
        <xsl:value-of select="'T'"/>
        <xsl:value-of select="concat(
            format-number($h,'00'),':',
            format-number($m,'00'),':',
            format-number($seconds,'00'))
            "/>
        <xsl:if test="$is_include_milliseconds">
            <xsl:value-of select="concat('.',format-number($utctimestampmilliseconds mod 1000,'000'))"/>
        </xsl:if>
        <xsl:value-of select="$timezonepart"/>        
        
    </xsl:template>

</xsl:stylesheet>
