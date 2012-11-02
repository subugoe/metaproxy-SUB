<?xml version="1.0" encoding="UTF-8"?>
<!--
	Provides the template »iso-639-2-cleaner« with parameter »languageCode« that
		* replaces ISO-639-2/T codes with their ISO-639-2/B equivalent
		* replaces deprecated ISO-639-2/B codes with their current version
		* leaves all strings noth matching ISO-639-2/T oder deprecated /B codes untouched

	Information:
		* http://www.loc.gov/standards/iso639-2/ascii_8bits.html
		* http://www.loc.gov/marc/languages/
		* http://www.loc.gov/marc/languages/language_code.html

	2010-2012 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


	<xsl:template name="iso-639-2-cleaner">
		<xsl:param name="languageCode"/>

		<xsl:choose>
			<!-- Ensure we have ISO 639-2/B language codes -->
			<xsl:when test="$languageCode = 'sqi'">alb</xsl:when>
			<xsl:when test="$languageCode = 'hye'">arm</xsl:when>
			<xsl:when test="$languageCode = 'eus'">baq</xsl:when>
			<xsl:when test="$languageCode = 'mya'">bur</xsl:when>
			<xsl:when test="$languageCode = 'zho'">chi</xsl:when>
			<xsl:when test="$languageCode = 'ces'">cze</xsl:when>
			<xsl:when test="$languageCode = 'nld'">dut</xsl:when>
			<xsl:when test="$languageCode = 'fra'">fre</xsl:when>
			<xsl:when test="$languageCode = 'kat'">geo</xsl:when>
			<xsl:when test="$languageCode = 'deu'">ger</xsl:when>
			<xsl:when test="$languageCode = 'ell'">gre</xsl:when>
			<xsl:when test="$languageCode = 'isl'">ice</xsl:when>
			<xsl:when test="$languageCode = 'mkd'">mac</xsl:when>
			<xsl:when test="$languageCode = 'mri'">mao</xsl:when>
			<xsl:when test="$languageCode = 'msa'">may</xsl:when>
			<xsl:when test="$languageCode = 'fas'">per</xsl:when>
			<xsl:when test="$languageCode = 'ron'">rum</xsl:when>
			<xsl:when test="$languageCode = 'slk'">slo</xsl:when>
			<xsl:when test="$languageCode = 'bod'">tib</xsl:when>
			<xsl:when test="$languageCode = 'cym'">wel</xsl:when>

			<!-- Replace deprecated ISO 639-2 language codes with current versions -->
			<xsl:when test="$languageCode = 'esk'">kal</xsl:when>
			<xsl:when test="$languageCode = 'esp'">epo</xsl:when>
			<xsl:when test="$languageCode = 'eth'">gez</xsl:when>
			<xsl:when test="$languageCode = 'far'">fao</xsl:when>
			<xsl:when test="$languageCode = 'gae'">gla</xsl:when>
			<xsl:when test="$languageCode = 'gag'">glg</xsl:when>
			<xsl:when test="$languageCode = 'iri'">gle</xsl:when>
			<xsl:when test="$languageCode = 'cam'">khm</xsl:when>
			<xsl:when test="$languageCode = 'mla'">mlg</xsl:when>
			<xsl:when test="$languageCode = 'max'">glv</xsl:when>
			<xsl:when test="$languageCode = 'lan'">oci</xsl:when>
			<xsl:when test="$languageCode = 'gal'">orm</xsl:when>
			<xsl:when test="$languageCode = 'lap'">smi</xsl:when>
			<xsl:when test="$languageCode = 'sao'">smo</xsl:when>
			<xsl:when test="$languageCode = 'sho'">sna</xsl:when>
			<xsl:when test="$languageCode = 'scc'">srp</xsl:when>
			<xsl:when test="$languageCode = 'snh'">sin</xsl:when>
			<xsl:when test="$languageCode = 'swz'">ssw</xsl:when>
			<xsl:when test="$languageCode = 'taj'">tgk</xsl:when>
			<xsl:when test="$languageCode = 'tag'">tgl</xsl:when>
			<xsl:when test="$languageCode = 'tar'">tat</xsl:when>
			<xsl:when test="$languageCode = 'tsw'">tsn</xsl:when>

			<!-- The potentially non-unique cases. May be better left out -->
			<xsl:when test="$languageCode = 'sso'">sot</xsl:when>
			<xsl:when test="$languageCode = 'fri'">frr</xsl:when>

			<!-- Without a match, keep the existing language code -->
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
