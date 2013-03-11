<?xml version="1.0" encoding="UTF-8"?>
<!--
	Add attribute »zvdd-id« to <mods> tag with ZVDD identifier.

	2013 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="mods:mods/mods:recordInfo">
		<mods:recordInfo>
			<mods:recordIdentifier type="zvdd">
				<xsl:value-of select="../@zvdd-id"/>
			</mods:recordIdentifier>
		</mods:recordInfo>
	</xsl:template>

</xsl:stylesheet>