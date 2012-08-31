<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:mp="http://indexdata.com/metaproxy"
	xmlns:e="http://explain.z3950.org/dtd/2.0/"
	version="1.0">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>



	<!-- Remove blanks. -->
	<xsl:template match="text()"/>



	<!--
		Root element:
			* create records element
			* add explain element converted from metaproxy torus records as children
	-->
	<xsl:template match="/">
		<mp:filter id="sru" type="sru_z3950">
			<xsl:for-each select="records/e:explain/e:serverInfo/e:database">
				<xsl:call-template name="databaseExplain"/>
			</xsl:for-each>
		</mp:filter>
	</xsl:template>



	<!--
		For each database name, create a <database> element with an XInclude
		tag to load the database’s explain information.
	-->
	<xsl:template name="databaseExplain">
		<mp:database>
			<xsl:attribute name="name">
				<xsl:value-of select="."/>
			</xsl:attribute>
			<xi:include>
				<xsl:attribute name="href">
					<xsl:text>explain/</xsl:text>
					<xsl:value-of select="translate(., '/', '_')"/>
					<xsl:text>.xml</xsl:text>
				</xsl:attribute>
			</xi:include>
		</mp:database>
	</xsl:template>



</xsl:stylesheet>
