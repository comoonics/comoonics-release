<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" indent="no" omit-xml-declaration="yes"/>
    
    <!-- grouping done via: http://sources.redhat.com/ml/xsl-list/2000-07/msg00458.html -->
    <xsl:key name="products" match="bug" use="product" />
    <xsl:key name="components" match="bug" use="component" />
    <xsl:key name="versions" match="bug" use="version" />
    <xsl:key name="bug_severities" match="bug" use="bug_severity" />
    
    <xsl:template match="bug" mode="version">
        <xsl:if test="position()=1">id: {filename}
title: Releasenotes of <xsl:value-of select='concat(product, " Version ", version)'/>
description: releasenotes description
Content-Type: text/html
</xsl:if>
    </xsl:template>

    <xsl:template match="bug">
        <xsl:apply-templates
            select="//bug[generate-id(.) = generate-id(key('versions', version)[1])]" mode="version">
            <xsl:sort select="./version" order="descending"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="bugzilla">
        <xsl:apply-templates select="bug[generate-id(.) = generate-id(key('products', product)[1])]">
            <xsl:sort select="version" order="descending"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:apply-templates select="bugzilla"/>
    </xsl:template>
</xsl:stylesheet>