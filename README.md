Modules:
=

date
=========

Converts xs:date xs:datetime to timestamp (also known as epoch) and back

Example:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="https://github.com/ilyakharlamov/pure-xsl/date"
    version="1.0">
    <xsl:import href="https://raw.github.com/ilyakharlamov/pure-xsl/master/date.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="time_as_timestamp" select="1365599995640"/>
        <xsl:text>time_as_timestamp:</xsl:text><xsl:value-of select="$time_as_timestamp"/><xsl:text>&#x0A;</xsl:text>
        <xsl:variable name="time_as_xsdatetime">
            <xsl:call-template name="date:date-time">
                <xsl:with-param name="timestamp" select="$time_as_timestamp"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>time_as_xsdatetime:</xsl:text><xsl:value-of select="$time_as_xsdatetime"/><xsl:text>&#x0A;</xsl:text>
        <xsl:text>converted back:</xsl:text>
        <xsl:call-template name="date:timestamp">
            <xsl:with-param name="date-time" select="$time_as_xsdatetime"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
```

Output:
<pre>time_as_timestamp:1365599995640
time_as_xsdatetime:2013-04-10T13:19:55.640Z
converted back:1365599995640
</pre>

parseStringAsXML

=========
Example:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pxml="https://github.com/ilyakharlamov/pure-xsl/parseStringAsXML"
    version="1.0">
    <xsl:import href="https://raw.github.com/ilyakharlamov/pure-xsl/master/parseStringAsXML.xsl"/>
    <xsl:template match="/">
        <xsl:call-template name="pxml:parseContent">
            <xsl:with-param name="escaped">  &lt;root&gt;   &lt;field attr1 = "value1" attr2 = 'value2'&gt;&lt;name/&gt;&lt;/field&gt;&lt;field&gt;te&amp;lt;xt&lt;/field&gt; &lt;/root&gt;</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
```

Output:
```
<root>   
   <field attr1="value1" attr2="value2">
      <name/>
   </field>
   <field>te&lt;xt</field> 
</root>
```
