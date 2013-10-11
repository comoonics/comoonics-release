<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="flag">
        <flag>
            <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
            <xsl:attribute name="status"><xsl:value-of select="@status"/></xsl:attribute>
            <xsl:attribute name="setter"><xsl:value-of select="@setter"/></xsl:attribute>
        </flag>
    </xsl:template>

    <xsl:template match="bug">
        <bug>
            <bug_id><xsl:value-of select="bug_id"/></bug_id>
            <short_desc><xsl:value-of select="short_desc"/></short_desc>
            <bug_severity><xsl:value-of select="bug_severity"/></bug_severity>
            <component><xsl:value-of select="component"/></component>
            <product><xsl:value-of select="product"/></product>
            <xsl:apply-templates select="flag"/>
        </bug>
    </xsl:template>

    <xsl:template match="bugzilla">
        <bugzilla>
            <xsl:apply-templates
                select="bug" />
        </bugzilla>
    </xsl:template>

    <xsl:template match="/">
        <xsl:apply-templates select="bugzilla"/>
    </xsl:template>
    
</xsl:stylesheet>