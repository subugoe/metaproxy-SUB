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


	<!-- Add @and @attr 1=zvdd.iswork 1 to the query. -->
	<xsl:template match="rpn">
		<rpn>
		    <xsl:attribute name="set">
		    	<xsl:value-of  select="@set"/>
		    </xsl:attribute>
			<operator type="and">
				<operator type="or">
					<apt>
						<attr type="1" value="iswork"/>
						<term type="general">1</term>
					</apt>
					<apt>
						<attr type="1" value="docstrct"/>
						<term type="general">Article</term>
					</apt>
				</operator>
				<xsl:apply-templates/>
			</operator>
		</rpn>
	</xsl:template>


</xsl:stylesheet>
