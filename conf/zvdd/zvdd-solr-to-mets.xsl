<?xml version="1.0" encoding="UTF-8"?>
<!--
	Output METS records for ZVDD Solr documents.

	* get PPN field from ZVDD Solr record
	* use the PPN to build URL for loading METS data
	* load METS record and insert it into the record along with its URL

	2012-2013 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../../xsl/url-encode.xsl"/>
	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<!-- Remove stray text. -->
	<xsl:template match="text()"/>


	<!-- Turn Solr documents into <record> elements and process their children. -->
	<xsl:template match="doc">
		<record>
			<xsl:apply-templates match="arr[@name='PPN']/str"/>
		</record>
	</xsl:template>




	<!--
		Take the PPN array, create the URL for each PPN, escaping the term in the process,
		load the METS file from that address and insert both the URL and the METS.
	-->
	<xsl:template match="arr[@name='PPN']/str">
		<xsl:variable name="METSURL">
			<xsl:text>http://www.zvdd.de/dms/metsresolver/?PPN=</xsl:text>
			<xsl:call-template name="url-encode">
				<xsl:with-param name="str" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<mets-url>
			<xsl:value-of select="$METSURL"/>
		</mets-url>

		<xsl:copy-of select="document($METSURL)"/>
	</xsl:template>

</xsl:stylesheet>