<?xml version="1.0" encoding="UTF-8"?>
<!--
	Output the MODS record in ZVDD Solr documents.

	Solr needs to be queried with the special xmlpassthrough stylesheet
		https://gist.github.com/ssp/4723573
	configured to pass on the field »mods« to return the tags of the structured
	MODS data as an unescaped string.

	A »&wt=xslt&tr=xmlpassthrough.xsl« needs to be appended to the Solr query for the
	stylesheet to be invoked. A reverse proxy in our vhost configuration takes care
	of that.

	2013 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	xmlns:mods="http://www.loc.gov/mods/v3"
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<!-- Remove stray text. -->
	<xsl:template match="text()"/>


	<!-- Turn Solr documents into <record> elements and process their children. -->
	<xsl:template match="doc">
		<xsl:apply-templates/>
	</xsl:template>


	<!--
		Match xml/mods tags.
		Copy them and their children with an added mods namespace.
		Strip leading and trailing whitespace from the contained text.
	-->
	<xsl:template match="xml/mods">
		<mods:mods>
			<xsl:copy-of select="namespace::*"/>
			<xsl:apply-templates select="./*" mode="addMODSNS"/>
		</mods:mods>
	</xsl:template>

	<xsl:template match="*" mode="addMODSNS">
		<xsl:element name="mods:{local-name()}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="node()|text()" mode="addMODSNS"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="text()" mode="addMODSNS">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

</xsl:stylesheet>