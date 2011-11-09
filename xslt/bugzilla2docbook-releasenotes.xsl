<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" doctype-public="-//OASIS//DTD DocBook XML V4.2//EN" doctype-system="/usr/share/sgml/docbook/xml-dtd-4.5-1.0-33.fc8/docbookx.dtd" indent="yes"/>

    <!-- grouping done via: http://sources.redhat.com/ml/xsl-list/2000-07/msg00458.html -->
    <xsl:key name="products" match="bug" use="product" />
    <xsl:key name="components" match="bug" use="component" />
    <xsl:key name="versions" match="bug" use="version" />
    <xsl:key name="flags" match="flag" use="@name"/>
    <xsl:key name="bug_severities" match="bug" use="bug_severity" />
    
    <xsl:template match="long_desc">
        <listitem>
            <para><xsl:value-of select="./thetext"/></para>
        </listitem>
    </xsl:template>
    
    <xsl:template match="bug" mode="bugreport">
        <varlistentry>
            <term>
                <xsl:value-of select='concat(./bug_id, ": ", ./short_desc)'/>  
            </term>
            <listitem>
                <xsl:choose>
                    <xsl:when test="./cf_releasenotes">
                        <para>
                            <xsl:value-of select="./cf_releasenotes"/>    
                        </para>
                    </xsl:when>
                    <xsl:otherwise>
                        <para>No release notes found.</para>
                    </xsl:otherwise>
                </xsl:choose>
            </listitem>
        </varlistentry>
    </xsl:template>
                           
    <xsl:template match="bug" mode="bug_severity">
        <xsl:param name="version" select="./version"/>
        <xsl:param name="flag" select="./flag/@name"/>
        <xsl:param name="component" select="./component"/>
        <xsl:param name="bug_severity" select="./bug_severity"/>
                <sect4>
                    <title><xsl:value-of select="$bug_severity"/></title>
                    <variablelist>
                        <xsl:for-each select="//bug[bug_severity = $bug_severity and flag/@name = $flag and component = $component]">
                            <xsl:apply-templates select="." mode="bugreport">
                                <xsl:with-param name="version" select="$version"/>
                                <xsl:with-param name="flag" select="$flag"/>
                                <xsl:with-param name="component" select="$component"/>
                                <xsl:with-param name="bug_severity" select="$bug_severity"/>
                            </xsl:apply-templates>
                        </xsl:for-each>
                    </variablelist>
                </sect4>
    </xsl:template>
    
    <xsl:template match="bug" mode="version">
        <xsl:param name="version" select="./version"/>
        <xsl:param name="flag" select="./flag/@name"/>
        <xsl:param name="component" select="./component"/>
        <xsl:param name="bug_severity" select="./bug_severity"/>
        <sect3>
            <title><xsl:value-of select="$version"/></title>
            <xsl:apply-templates
                select="//bug[generate-id(.) = generate-id(key('bug_severities', bug_severity)[1]) and version = $version and flag/@name = $flag and component = $component]" mode="bug_severity">
                <xsl:with-param name="version" select="$version"/>
                <xsl:with-param name="flag" select="$flag"/>
                <xsl:with-param name="component" select="$component"/>
                <xsl:with-param name="bug_severity" select="$bug_severity"/>
            </xsl:apply-templates>
        </sect3>
    </xsl:template>

    <xsl:template match="flag" mode="flag">
        <xsl:param name="version" select="./version"/>
        <xsl:param name="flag" select="./@name"/>
        <xsl:param name="component" select="./component"/>
        <xsl:param name="bug_severity" select="./bug_severity"/>
        <sect3>
            <title><xsl:value-of select="$flag"/></title>
            <xsl:for-each select="//bug[component=$component and ./flag/@name=$flag]">
                <x>bug <xsl:value-of select='concat($component, " ", $flag, " ",./bug_id, " ", ./bug_severity)'/></x>                
            </xsl:for-each>
            
            <xsl:apply-templates
                select="//bug[component=$component and ./flag/@name=$flag and generate-id(.) = generate-id(key('bug_severities', ./bug_severity)[1])]" mode="enum">
                <xsl:with-param name="flag" select="$flag"/>
                <xsl:with-param name="component" select="$component"/>
            </xsl:apply-templates>
        </sect3>
    </xsl:template>
    
    <xsl:template match="bug" mode="component">
        <xsl:param name="version" select="./version"/>
        <xsl:param name="flag" select="./flag[starts-with(@name,'comoonics-')]/@name"/>
        <xsl:param name="component" select="./component"/>
        <xsl:param name="bug_severity" select="./bug_severity"/>
        <sect2>
            <title><xsl:value-of select="$component"/> bla <xsl:value-of select="generate-id(.)"/> == <xsl:value-of select="generate-id(key('flags', ./flag/@name)[1])"/></title>
<!--            <xsl:for-each
                select="//bug[component=$component]/flag[generate-id(.) = generate-id(key('flags', ./@name)[1])]">
                <x><xsl:value-of select="./@name"></xsl:value-of></x>
            </xsl:for-each>-->
            <xsl:apply-templates select="//bug[component=$component]/flag[generate-id(.) = generate-id(key('flags', ./@name)[1])]" mode="enum">
                <xsl:with-param name="component" select="$component"/>
            </xsl:apply-templates>
        </sect2>
    </xsl:template>
    
    <xsl:template match="flag" mode="enum">
        <xsl:param name="version" select="./version"/>
        <xsl:param name="flag" select="./@name"/>
        <xsl:param name="component" select="./component"/>
        <xsl:param name="bug_severity" select="./bug_severity"/>
        <enum><xsl:value-of select='concat($component, " ", $flag)'/></enum>
        <xsl:for-each select="//bug[component=$component and ./flag/@name=$flag]">
            <para>Bug <xsl:value-of select="./bug_id"/></para>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="bug" mode="enum">
        <xsl:param name="version" select="./version"/>
        <xsl:param name="component" select="./component"/>
        <xsl:param name="bug_severity" select="./bug_severity"/>
        <para>Bug <xsl:value-of select="$component"/></para>

        <xsl:for-each select='//bug/flag[starts-with(@name, "comoonics-") and generate-id(.) = generate-id(key("flags", @name)[1])]'>
            <xsl:variable name="flag" select="./@name"/>
            <flag><xsl:value-of select='concat($flag, "=", @name)'/></flag>
            <xsl:for-each select='//bug[component=$component and flag[starts-with(@name, "comoonics-")]/@name=$flag]'>
<!--                <bug>Bug <xsl:value-of select='concat(bug_id, " ", flag/@name)'></xsl:value-of></bug>-->
            </xsl:for-each>
<!--                <para>Flags: 
                    <xsl:value-of select="@name"/>-->
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="bug">
        <article>
            <articleinfo>
                
                <title>Release notes for product <xsl:value-of select="./product"/></title>
                
                <author>
                    <firstname>Marc</firstname>
                    <surname>Grimme</surname>
                    <affiliation>
                        <!-- Valid email...spamblock/scramble if so desired -->
                        <address><email>grimme (at) atix.de</email></address>
                    </affiliation>
                </author>
            </articleinfo>
            
            <sect1 id="intro">
                <title>Introduction</title>
                <para>Test123</para>
            </sect1>
            
            <sect1>
                <title>Release Notes</title>
                <xsl:apply-templates
                    select="//bug[generate-id(.) = generate-id(key('components', component)[1])]" mode="enum"/>
            </sect1>
         </article>
    </xsl:template>
    
    <xsl:template match="bugzilla">
        <xsl:apply-templates
             select="bug[generate-id(.) = generate-id(key('products', product)[1])]" />
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:apply-templates select="bugzilla"/>
    </xsl:template>
</xsl:stylesheet>    