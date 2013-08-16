<?xml version="1.0" encoding="UTF-8"?>
<!--
	Stylesheet to find out the order in which XSL selets nodes.
	
	2013 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="/xml">
		<xsl:for-each select="a | b">
			<xsl:value-of select="local-name()"/>
		</xsl:for-each>
	</xsl:template>
		
</xsl:stylesheet>