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


	<xsl:template match="arr">
		<xsl:variable name="field" select="@name"/>

		<xsl:for-each select="str">
			<xsl:element name="dc:{$field}" namespace="http://purl.org/dc/elements/1.1/">
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>

	</xsl:template>


</xsl:stylesheet>