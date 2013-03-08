<?xml version="1.0" encoding="UTF-8"?>
<!--
	Cleans MARCXML output:
		* removes new lines
		* cleans up namespaces

	2013, Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	xmlns:marc="http://www.loc.gov/MARC21/slim"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="marc"
	version="1.0">

	<xsl:output method="xml" indent="yes"/>


	<!-- Record root node: ensure we have a namespace URL but no namespace name here. -->
	<xsl:template match="marc:record">
		<record xmlns="http://www.loc.gov/MARC21/slim">
			<xsl:apply-templates select="*"/>
		</record>
	</xsl:template>


	<!-- Copy tags with non-empty content. Ensure they have no namespace. -->
	<xsl:template match="*">
		<xsl:if test="string-length(normalize-space(.)) &gt; 0">
			<xsl:element name="{local-name()}">
				<xsl:apply-templates select="@*|node()"/>
			</xsl:element>
		</xsl:if>
 	</xsl:template>


 	<!-- Copy attributes. -->
	<xsl:template match="@*">
		<xsl:copy/>
 	</xsl:template>


</xsl:stylesheet>