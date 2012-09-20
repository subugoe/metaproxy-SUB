<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<!-- Remove stray text. -->
	<xsl:template match="text()"/>


	<!-- Turn Solr documents into <record> elements and process their children. -->
	<xsl:template match="doc">
		<record>
			<xsl:apply-templates match="arr"/>
		</record>
	</xsl:template>


	<!-- Remove generic arrays. -->
	<xsl:template match="arr"/>


	<!--
		Take the PPN array, create the URL for each PPN, escaping the term in the process,
		load the METS file from that address and insert both the URL and the METS.
	-->
	<xsl:template match="arr[@name='PPN']">
		<xsl:variable name="METSURL">
			<xsl:text>http://www.zvdd.de/dms/metsresolver/?PPN=</xsl:text>
			<xsl:call-template name="url-encode">
				<xsl:with-param name="str" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<mets-url>
			<xsl:value-of select="$METSURL"/>
		</mets-url>
		<xsl:for-each select="str">
			<xsl:copy-of select="document($METSURL)"/>
		</xsl:for-each>
	</xsl:template>


	<!--
		Percent Escapes for ASCII.

		Taken from Mike J. Brown’s url-encode.xsl, available at
		http://skew.org/xml/stylesheets/url-encode/url-encode.xsl
	-->
	<xsl:template name="url-encode">
		<xsl:param name="str"/>
		<xsl:variable name="ascii"> !"#$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~</xsl:variable>
		<!-- Characters that usually don't need to be escaped -->
		<xsl:variable name="safe">!'()*-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~</xsl:variable>
		<xsl:variable name="hex" >0123456789ABCDEF</xsl:variable>

		<xsl:if test="$str">
			<xsl:variable name="first-char" select="substring($str,1,1)"/>
			<xsl:choose>
				<xsl:when test="contains($safe,$first-char)">
					<xsl:value-of select="$first-char"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="codepoint">
						<xsl:choose>
							<xsl:when test="contains($ascii,$first-char)">
								<xsl:value-of select="string-length(substring-before($ascii,$first-char)) + 32"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message terminate="no">Warning: string contains a character that is out of range! Substituting "?".</xsl:message>
								<xsl:text>63</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
				<xsl:variable name="hex-digit1" select="substring($hex,floor($codepoint div 16) + 1,1)"/>
				<xsl:variable name="hex-digit2" select="substring($hex,$codepoint mod 16 + 1,1)"/>
				<xsl:value-of select="concat('%',$hex-digit1,$hex-digit2)"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="string-length($str) &gt; 1">
				<xsl:call-template name="url-encode">
					<xsl:with-param name="str" select="substring($str,2)"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>