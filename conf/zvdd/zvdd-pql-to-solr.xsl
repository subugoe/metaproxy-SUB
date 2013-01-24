<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<!-- Copy nodes and attributes. -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<!--
		Match @attr 1= and its Z39.50 index numbers by the corresponding Solr Index names.
		Completely remove the @attr=1 for index 1016 to use Solr’s default index.
	-->
	<xsl:template match="attr[@type='1']">
		<xsl:if test="@value != '1016'">
			<attr type="1">
				<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="@value = '4'">
							<xsl:text>TITLE</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '1004'">
							<xsl:text>CREATOR</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '12'">
							<xsl:text>PPN</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '9999'">
							<xsl:text>ISWORK</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</attr>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
