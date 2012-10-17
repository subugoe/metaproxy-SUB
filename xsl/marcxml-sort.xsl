<?xml version="1.0" encoding="UTF-8"?>
<!--
	Sorts the fields of a MARC record to be in numerically increasing order.

	2012, Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:marc="http://www.loc.gov/MARC21/slim">

	<xsl:output method="xml" indent="yes"/>


	<!-- Copy -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<!-- Grab the record, copy the leader and sort the control and data fields. -->
	<xsl:template match="marc:record">
		<xsl:copy>
			<xsl:apply-templates select="marc:leader"/>

			<xsl:for-each select="marc:controlfield">
				<xsl:sort select="@tag"/>
				<xsl:apply-templates select="."/>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield">
				<xsl:sort select="@tag"/>
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>