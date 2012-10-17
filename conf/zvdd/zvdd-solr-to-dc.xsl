<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<!-- Remove stray text. -->
	<xsl:template match="text()"/>


	<!-- Turn Solr documents into <record> elements and process their children. -->
	<xsl:template match="doc">
		<record>
			<xsl:apply-templates match="arr"/>
		</record>
	</xsl:template>


	<!-- Remove generic arrays. -->
	<xsl:template match="arr"/>


	<!--
		Map the Solr fields to Dublin Core.
	-->
	<xsl:template match="arr[@name='CREATOR']">
		<xsl:for-each select="str">
			<dc:creator>
				<xsl:value-of select="."/>
			</dc:creator>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="arr[@name='TITLE']">
		<xsl:for-each select="str">
			<dc:title>
				<xsl:value-of select="."/>
			</dc:title>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="arr[@name='YEARPUBLISH']">
		<xsl:for-each select="str">
			<dc:date>
				<xsl:value-of select="."/>
			</dc:date>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="arr[@name='PUBLISHER']">
		<xsl:for-each select="str">
			<dc:publisher>
				<xsl:value-of select="."/>
			</dc:publisher>
		</xsl:for-each>
	</xsl:template>



</xsl:stylesheet>