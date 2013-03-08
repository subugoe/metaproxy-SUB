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
	exclude-result-prefixes=""
	version="1.0">

	<xsl:output method="xml" indent="yes"/>


	<!-- Copy tags with non-empty content. -->
	<xsl:template match="node()">
		<xsl:if test="string-length(normalize-space(.)) &gt; 0">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
 	</xsl:template>

 	<!-- Copy attributes. -->
	<xsl:template match="@*">
		<xsl:copy/>
 	</xsl:template>


</xsl:stylesheet>