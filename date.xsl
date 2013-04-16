<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="https://github.com/ilyakharlamov/xslt-date.git"
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
        <xsl:param name="timestamp"/>
        <xsl:if test="not(format-number($timestamp,0)='NaN')">
            <xsl:variable name="days"
                select="$timestamp div (24*3600000)"/>
            <xsl:variable name="time"
                select="
                $timestamp div 1000
                -floor($days)*24*3600"/>
            <xsl:variable name="year"
                select="
                1970+floor(
                format-number($days div 365.24,'0.#'))"/>
            <xsl:variable name="year-offset"
                select="
                719528-$year*365
                -floor($year div 4)
                +floor($year div 100)
                -floor($year div 400)
                +floor($days)"/>
            <xsl:variable name="month"
                select="count($date:month/*[$year-offset>=sum(preceding-sibling::*)][last()]/preceding-sibling::*)"/>
            <xsl:variable name="hours"
                select="floor($time div 3600)"/>
            <xsl:variable name="min"
                select="floor($time div 60-$hours*60)"/>
            <xsl:variable name="sec"
                select="floor($time -$hours*3600-$min*60)"/>
            <xsl:value-of select="
                concat(
                format-number($year,'0000'),'-',
                format-number($month+1,'00'),'-',
                format-number(
                $year-offset
                -sum($date:month/*[$month>=position()])
                +(2>$month and (($year mod 4=0 and
                $year mod 100!=0) or
                $year mod 400=0)),
                '00'),'T',
                format-number($hours,'00'),':',
                format-number($min,'00'),':',
                format-number($sec,'00'),'.',
                format-number(
                1000*($time
                -$hours*3600
                -$min*60-$sec),
                '000'),'Z')"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>