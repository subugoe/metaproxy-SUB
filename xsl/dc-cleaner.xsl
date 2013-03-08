<?xml version="1.0" encoding="UTF-8"?>
<!--
	Cleans DC XML output:
		* removes new lines
		* removes DC namespace

	2013, Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
	xmlns:srw_dc="info:srw/schema/1/dc-schema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes=""
	version="1.0">

	<xsl:output method="xml" indent="yes"/>


	<xsl:template match="oai_dc:dc">
		<record>
			<xsl:apply-templates select="*"/>
		</record>
	</xsl:template>

	<!-- Copy tags with non-empty content. -->
	<xsl:template match="@*|node()">
		<xsl:if test="string-length(.) &gt; 0">
			<xsl:copy>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
 	</xsl:template>


</xsl:stylesheet>