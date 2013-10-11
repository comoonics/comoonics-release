<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes" doctype-public="-//OASIS//DTD DocBook XML V4.5//EN" 
        doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd"/>
    <xsl:param name="productversion">unknown</xsl:param>
    <xsl:template match="bug" mode="display">
        <xsl:param name="component" select="component"/>
        <xsl:param name="product" select="product"/>
        <xsl:param name="flag" select="flag[starts-with(@name, 'comoonics-')]/@name"/>
        <xsl:param name="bug_severity" select="bug_severity"/>
        
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

    <xsl:template match="bug_severity">
        <xsl:param name="component" select="."/>
        <xsl:param name="product" select="../product"/>
        <xsl:param name="flag" select="./flag[starts-with(@name, 'comoonics-')]/@name"/>
        <xsl:param name="bug_severity" select="."/>
        <sect4>
            <title><xsl:value-of select="$bug_severity"/></title>
            <variablelist>
                <xsl:for-each-group select="//bug[product=$product and component=$component and flag/@name=$flag and bug_severity=$bug_severity]" group-by="bug_id">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="." mode="display">
                        <xsl:with-param name="product" select="$product"/>
                        <xsl:with-param name="component" select="$component"/>
                        <xsl:with-param name="flag" select="$flag"/>
                        <xsl:with-param name="bug_severity" select="$bug_severity"/>
                    </xsl:apply-templates>
                </xsl:for-each-group>
            </variablelist>
        </sect4>
        
    </xsl:template>

    <xsl:template match="flag">
        <xsl:param name="component" select="."/>
        <xsl:param name="product" select="../product"/>
        <xsl:param name="flag" select="@name"/>
        
        <sect3>
            <title><xsl:value-of select="$flag"/></title>
            <xsl:for-each-group select="//bug[product=$product and component=$component and flag/@name=$flag]" group-by="bug_severity">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:apply-templates select="./bug_severity">
                    <xsl:with-param name="product" select="$product"/>
                    <xsl:with-param name="component" select="$component"/>
                    <xsl:with-param name="flag" select="$flag"/>
                </xsl:apply-templates>
            </xsl:for-each-group>
        </sect3>
                
    </xsl:template>

    <xsl:template match="component">
        <xsl:param name="component" select="."/>
        <xsl:param name="product" select="../product"/>
        <sect2>
            <title><xsl:value-of select="$component"/></title>
            <xsl:for-each-group select="//bug[product=$product and component=$component]/flag[starts-with(@name, 'comoonics-')]" group-by="@name">
                <xsl:sort select="current-grouping-key()" order="descending"/>
                <xsl:apply-templates select=".">
                    <xsl:with-param name="product" select="$product"/>
                    <xsl:with-param name="component" select="$component"/>
                </xsl:apply-templates>
            </xsl:for-each-group>
        </sect2>
    </xsl:template>

    <xsl:template match="product">
        <xsl:param name="product" select="."/>
        <sect1>
            <title>Release Notes for <xsl:value-of select="$product"/></title>
            <xsl:for-each-group select="//bug[product=$product]" group-by="./component">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:apply-templates select="./component">
                    <xsl:with-param name="product" select="$product"/>
                </xsl:apply-templates>
            </xsl:for-each-group>
        </sect1>
    </xsl:template>
    
    <xsl:template match="bugzilla">
        <article>
            <articleinfo>
                <!--                <title><inlinegraphic align="center" scale="20" fileref="images/ATIX-logo-positiv.jpg"/> Release notes for the <inlinegraphic scale="80" fileref="images/com.oonics-enterprise-it-platform-v1.jpg"/></title>-->
                <title>Release notes for the com.oonics Enterprise IT Platform Version <xsl:value-of select="$productversion"/></title>
                <address>ATIX Informationstechnologie und Consulting AG
                    <state>Einsteinstrasse 10</state>
                    <city>Unterschleissheim</city>
                    <country>Germany</country>
                    <email>info@atix.de</email>
                    <fax>+49 89 9901766-0</fax>
                    <phone>+49 89 4523538-0</phone>
                    <postcode>85716</postcode>
                </address>
                <copyright>
                    <year>2011</year>
                    <holder>ATIX AG</holder>
                </copyright>
                <legalnotice>
                    <para>Copyright © 2011 ATIX Informationstechnologie und Consulting AG, called “ATIX” within this document.</para>
                    <para>The text of and illustrations in this document are licensed by ATIX AG under a Creative Commons Attribution–Share Alike 3.0 Unported license 
                        ("CC-BY-SA"). 
                        An explanation of CC-BY-SA is available at http://creativecommons.org/licenses/by-sa/3.0/. In accordance with CC-BY-SA, 
                        if you distribute this document or an adaptation of it, you must provide the URL for the original version.</para>
                    <para>    ATIX AG, as the licensor of this document, waives the right to enforce, and agrees not to assert, Section 4d of CC-BY-SA to the fullest 
                        extent permitted by applicable law.</para>
                    <para>Red Hat, Red Hat Enterprise Linux are trademarks of Red Hat, Inc., registered in the United States and other countries.</para>
                    <para>Linux® is the registered trademark of Linus Torvalds in the United States and other countries.</para>
                    <para>All other trademarks are the property of their respective owners.</para>
                </legalnotice>
                <legalnotice>
                    <para>Note: This document is under development, is subject to substantial change, and is provided only as a preview. 
                        The included information and instructions should not be considered complete, and should be used with caution.
                    </para>
                </legalnotice>
            </articleinfo>            

            <sect1 id="intro">
                <title>Introduction</title>
                <para>The Release Notes provide high level coverage of the improvements and additions that have been implemented in the
                current com.oonics Enterprise IT Platform.</para>
                <para>For detailed documentation on all changes to the com.oonics Enterprise IT Platform update, refer to the ATIX Bugzilla.</para>
                <sect2>
                    <title>com.oonics Enterprise IT Platform Overview</title>
                    <para>
                    This part is intended to give an overview of features from a economical and technical perspective without going into details.</para>
                    <para>
                        The com.oonics Enterprise IT Platform consolidates server and storage systems. 
                        It enables high availability, optimal scalability and ease of management.
                        The com.oonics Enterprise IT Platform is suitable for companies of any size and can be adapted to meet the individual user's 
                        needs.
                        In time, the needs evolve. It is crucial to keep IT infrastructure modular and flexible, so that is easy to extend, upgrade or 
                        re-purpose. 
                        The com.oonics Enterprise IT Platform consists of flexible modules, industry-standard components based on Linux. 
                        Due to its open source nature, the Platform allows freedom, flexibility and ease of change.
                        Furthermore, the com.oonics Enterprise IT Platform solves the main challenges of modern IT – it optimizes the performance and 
                        availability of IT services and applications, such as file and web services, databases 
                        (Oracle, PostgreSQL, MaxDB, MySQL etc.), advanced ERP systems such as SAP and server virtualization. 
                        com.oonics is also a way to keep maintenance costs and TCO low.
                    </para>
                    <para>
                        The com.oonics modular IT infrastructure design may be depicted as follows:
                    </para>
                    <informalfigure>
                        <graphic scalefit="1" scale="25" fileref="images/com.oonics-Enterprise-IT-Platform.jpg"/>
                    </informalfigure>
                    <para>
                        Each server in the IT environment has direct access to SAN storage system. 
                        Servers may read and write on the shared storage concurrently. 
                        A shared file system enables parallel data access for all application servers. 
                        com.oonics allows servers to provide services as a cluster, without need of separate, local hard disks. 
                        Not only data and configuration are centralized but com.oonics Enterprise IT Platform allows the sharing of 
                        the operating system among cluster nodes.
                        The server hardware is logically assigned to clusters. 
                        The assignment is not static, it may be changed in cluster runtime, without downtime. 
                        For example, some database cluster servers (blue) may be reassigned and become web servers (yellow), without the need of 
                        costly downtime or maintenance window. 
                        This increases the manageability of the systems and allows flexible changes, e.g. in case of load peaks.
                        Since the cluster installation resides on SAN, it is easier to roll out and deploy new environment for production, 
                        tests or development. 
                        As long as the clustering and application software support it, a rolling update is significantly simplified.
                    </para>
                </sect2>
            </sect1>
            
            <xsl:for-each-group select="//bug" group-by="./product">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:apply-templates select="./product"/>
            </xsl:for-each-group>
        </article>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:apply-templates select="bugzilla"/>
    </xsl:template>
</xsl:stylesheet>