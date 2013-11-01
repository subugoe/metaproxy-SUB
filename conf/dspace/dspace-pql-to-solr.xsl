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
		Completely remove the @attr=1 for index 1010 (ALL) to use Solr’s default index.
		Numbers chosen in analogy to those used by sru.gbv.de/opac-de-7:
		http://opac.sub.uni-goettingen.de/DB=1/XML=1.0/IKTLIST
	-->
	<xsl:template match="attr[@type='1']">
		<xsl:if test="@value != '1010'">
			<attr type="1">
				<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="@value = '1016'">
							<xsl:text>metadata</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '1010'">
							<xsl:text></xsl:text>
						</xsl:when>
						<xsl:when test="@value = '12'">
							<xsl:text>handle</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '4'">
							<xsl:text>dc.title</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '1004'">
							<xsl:text>creator</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '31'">
							<xsl:text>dc.date.issued.year</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '54'">
							<xsl:text>dc.language.iso</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '21'">
							<xsl:text>dc.subject.all</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '8702'">
							<xsl:text>dc.subject.gok</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '13'">
							<xsl:text>dc.subject.ddc</xsl:text>
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
