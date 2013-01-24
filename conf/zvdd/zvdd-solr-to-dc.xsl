<?xml version="1.0" encoding="UTF-8"?>
<!--
	Output DC records for ZVDD Solr documents.

	Use the (few) fields that exist and map them to the corresponding DC elements.

	2012-2013 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../../xsl/url-encode.xsl"/>
	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<!-- Remove stray text. -->
	<xsl:template match="text()"/>


	<!-- Turn Solr documents into <record> elements and process their children. -->
	<xsl:template match="doc">
		<record>
			<xsl:apply-templates/>
		</record>
	</xsl:template>


	<!--
		Map the Solr fields to Dublin Core.
	-->
	<xsl:template match="arr[@name='CREATOR']/str | str[@name='CREATOR']">
		<dc:creator>
			<xsl:value-of select="."/>
		</dc:creator>
	</xsl:template>

	<xsl:template match="arr[@name='TITLE']/str | str[@name='TITLE']">
		<dc:title>
			<xsl:value-of select="."/>
		</dc:title>
	</xsl:template>

	<xsl:template match="arr[@name='YEARPUBLISH']/str | str[@name='YEARPUBLISH']">
		<dc:date>
			<xsl:value-of select="."/>
		</dc:date>
	</xsl:template>

	<xsl:template match="arr[@name='PUBLISHER']/str | str[@name='PUBLISHER']">
		<dc:publisher>
			<xsl:value-of select="."/>
		</dc:publisher>
	</xsl:template>

	<xsl:template match="arr[@name='LOCATION']/str | str[@name='LOCATION']">
		<xsl:variable name="METSURL">
			<xsl:text>http://www.zvdd.de/dms/metsresolver/?PPN=</xsl:text>
			<xsl:call-template name="url-encode">
				<xsl:with-param name="str" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<dc:relation>
			<xsl:value-of select="$METSURL"/>
		</dc:relation>
	</xsl:template>


</xsl:stylesheet>