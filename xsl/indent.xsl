<?xml version="1.0" encoding="UTF-8"?>
<!--
	Turn on indentation.

	2013 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

	<xsl:template match="/">
		<xsl:copy-of select="."/>
	</xsl:template>

</xsl:stylesheet>