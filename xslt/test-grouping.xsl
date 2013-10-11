<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html" indent="yes"/>

    <xsl:key name="rows" match="PROROW" use="name" />

    <xsl:template match="PROROW">

      <b><xsl:value-of select="name" /></b>
      <ul>
        <xsl:for-each select="key('rows', name)">
          <li>
            <a href="projects_results.xml?project={name}">
              <xsl:value-of select="project_name" />
            </a>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:template>
    <xsl:template match="PROJECTS">
        <xsl:apply-templates
            select="PROROW[generate-id(.) = generate-id(key('rows', name)[1])]" />
    </xsl:template>
    <xsl:template match="/">
        <xsl:apply-templates
            select="//PROJECTS" />
    </xsl:template>
</xsl:stylesheet>