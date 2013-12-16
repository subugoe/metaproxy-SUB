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
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<!-- Remove stray text. -->
	<xsl:template match="text()"/>


	<!-- Turn Solr documents into <record> elements and process their children. -->
	<xsl:template match="doc">
		<xsl:apply-templates/>
	</xsl:template>


	<!--
		Match xml/mods tags.
		Copy them and
		add the zvdd-id as recordInfo/recordIdentifier.
	-->
	<xsl:template match="xml/mods:mods">
		<mods:mods>
			<mods:recordInfo>
				<mods:recordIdentifier type="zvdd">
					<xsl:value-of select="../../str[@name='pid']"/>
				</mods:recordIdentifier>
			</mods:recordInfo>
			<xsl:copy-of select="*"/>
		</mods:mods>
	</xsl:template>

</xsl:stylesheet>