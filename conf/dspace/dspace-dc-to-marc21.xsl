<?xml version="1.0" encoding="UTF-8"?>
<!--
	Stylesheet for converting DSpace DC data to MARC records.
	Our DSpace systems provide fields beyond the standard DC, try to accomotate those.

	Overview of fields used by DSpace (not publicly accessible):
		https://docs.google.com/spreadsheet/ccc?key=0AnYBqnG_KlOjdHc5R2h4ZlpSenp0d3RDZVhBYXZjR0E

	2012 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns="http://www.loc.gov/MARC21/slim"
	exclude-result-prefixes="dc">

	<xsl:import href="../../xsl/iso-639-2-to-639-2b.xsl"/>



	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="dc:record | record">
		<record>

			<xsl:variable name="type" select="dc:type[1]"/>

			<leader>
				<!-- position 6: type of record: m (computer file) -->
				<xsl:variable name="leader06">m</xsl:variable>
				<!-- position 7: bibliographic level -->
				<xsl:variable name="leader07">
					<xsl:choose>
						<xsl:when test="$type='article'">a</xsl:when> <!-- monographic component part -->
						<xsl:when test="$type='collection'">c</xsl:when> <!-- collection -->
						<xsl:otherwise>m</xsl:otherwise> <!-- monograph -->
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="concat('      ', $leader06, $leader07, ' a22     3u 4500')"/>
			</leader>


			<controlfield tag="008">
				<!-- position 0-5: date -->
				<xsl:variable name="date">
					<xsl:choose>
						<xsl:when test="string-length(dc:date.accessioned_dt[1]) &gt;= 11">
							<xsl:value-of select="substring(dc:date.accessioned_dt[1], 3, 2)"/>
							<xsl:value-of select="substring(dc:date.accessioned_dt[1], 6, 2)"/>
							<xsl:value-of select="substring(dc:date.accessioned_dt[1], 9, 2)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>      </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="realDate">
					<xsl:choose>
						<xsl:when test="string-length($date) = 6">
							<xsl:value-of select="$date"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>      </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- position 6-14: leave blank -->
				<xsl:variable name="datefields">
					<xsl:text>         </xsl:text>
				</xsl:variable>
				<!-- position 15-17: unknown -->
				<xsl:variable name="place">
					<xsl:text>xx </xsl:text>
				</xsl:variable>
				<!-- position 18-34:
					 18-21: blank (undefined)
					 22: blank (target audience)
					 23: o (form of item: online resource)
					 24-25: blank (undefined)
					 26: d (type of computer file: document)
					 27: blank (undefined)
					 28: blank (government publication)
					 29-34: blank (undefined)
				-->
				<xsl:variable name="typespecific">
					<xsl:text>     o  d        </xsl:text>
				</xsl:variable>
				<!-- position: 35-37 language code -->
				<xsl:variable name="language">
					<xsl:choose>
						<xsl:when test="string-length(dc:language.iso[1]) = 3">
							<xsl:call-template name="iso-639-2-cleaner">
								<xsl:with-param name="languageCode" select="dc:language.iso[1]"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>  </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- position 38: modified record: blank (not modified) -->
				<xsl:variable name="modified">
					<xsl:text> </xsl:text>
				</xsl:variable>
				<!-- position 39: cataloguing source: d (other) -->
				<xsl:variable name="source">d</xsl:variable>

				<xsl:value-of select="concat($date, $datefields, $place, $typespecific, $language, $modified, $source)"/>
			</controlfield>



			<!--
				Additional language codes.
				First language code is in 008.
			-->
			<xsl:for-each select="dc:language.iso[position() &gt; 1]">
				<datafield tag="041" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:call-template name="iso-639-2-cleaner">
							<xsl:with-param name="languageCode" select="."/>
						</xsl:call-template>
					</subfield>
				</datafield>
			</xsl:for-each>






			<!-- PEOPLE -->


			<!--
				First author goes to 100 $a.
				Affiliation information in $u.
				Place of birth infomration is omitted.
			-->
			<xsl:for-each select="dc:contributor.author[1]">
				<datafield tag="100" ind1="1" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<xsl:if test="../dc:affiliation.institut">
						<subfield code="u">
							<xsl:for-each select="../dc:affiliation.institut[1]">
								<xsl:value-of select="."/>
							</xsl:for-each>
						</subfield>
					</xsl:if>
				</datafield>
			</xsl:for-each>


			<!--
				Additional authors go to 700 with $a aut (Author).
			-->
			<xsl:for-each select="dc:contributor.author[position()&gt;1]">
				<datafield tag="700" ind1="1" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="4">aut</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				First Corporation goes to 110.
			-->
			<xsl:for-each select="dc:contributor.corporation[1]">
				<datafield tag="110" ind1="2" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<!--
				Editor goes to 700 with $4 edt (Editor).
			-->
			<xsl:for-each select="dc:contributor.editor">
				<datafield tag="700" ind1="1" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="4">edt</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Advisor goes to 700 with $4 ths (Thesis Advisor).
			-->
			<xsl:for-each select="dc:contributor.advisor">
				<datafield tag="700" ind1="1" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="4">ths</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Referees go to 700 with $4 rev (Reviewer).
			-->
			<xsl:for-each select="dc:contributor.referee | dc:contributor.coReferee | dc:contributor.thirdReferee">
				<datafield tag="700" ind1="1" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="4">rev</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Corporations go to 110.
			-->
			<xsl:for-each select="dc:contributor.corporation">
				<datafield tag="110" ind1="2" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Meetings go to 111.
			-->
			<xsl:for-each select="dc:contributor.meeting">
				<datafield tag="111" ind1="2" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Other contributors go to 700 without $4.
			-->
			<xsl:for-each select="dc:contributor.other">
				<datafield tag="700" ind1="1" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>




			<!-- TITLE -->

			<!--
				Title (should be unique) goes to 245 $a.
				First title.translated goes to 245 $b.
				Additional title.translated goes to 246 $a.
				Title.alternative goes to 246 $a.
				Title.alternativeTranslated goes to 246 $a.
			-->
			<xsl:if test="dc:title">
				<datafield tag="245" ind1="0" ind2="0">
					<subfield code="a">
						<xsl:value-of select="dc:title[1]"/>
					</subfield>
					<xsl:if test="dc:title.translated">
						<subfield code="b">
							<xsl:value-of select="concat('= ', dc:title.translated[1])"/>
						</subfield>
					</xsl:if>
				</datafield>
			</xsl:if>

			<xsl:for-each select="dc:title.alternative | dc:title.translated[position &gt; 1] | dc:title.alternativeTranslated">
				<datafield tag="246" ind1="3" ind2="3">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>




			<!-- PUBLISHING AND ACCESS -->


			<!--
				First publisher and date.issued fields for 260.
				Additional publishers are lost. There should not be any in the incoming data.
			-->
			<xsl:if test="dc:publisher or dc:date.issued">
				<datafield tag="260" ind1=" " ind2=" ">
					<xsl:if test="dc:publisher">
						<subfield code="b">
							<xsl:value-of select="dc:publisher"/>
						</subfield>
					</xsl:if>
					<xsl:if test="dc:date.issued">
						<subfield code="c">
							<xsl:value-of select="dc:date.issued"/>
						</subfield>
					</xsl:if>
				</datafield>
			</xsl:if>


			<!--
				Extent goes to 300 $a.
			-->
			<xsl:for-each select="dc:format.extent[1]">
				<datafield tag="300" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				URI goes to 856 $u.
			-->
			<xsl:for-each select="dc:identifier.uri">
				<datafield tag="856" ind1="4" ind2=" ">
					<subfield code="u">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				METS URI goes to 856 $u with METS note in $y and MIME Type text/xml.
			-->
			<xsl:for-each select="dc:relation.mets">
				<datafield tag="856" ind1="4" ind2=" ">
					<subfield code="u">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="q">text/xml</subfield>
					<subfield cod="y">METS</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				URI to related data goes to 856 $u with data note in $y and ind2=2.
			-->
			<xsl:for-each select="dc:relation.isbasedon">
				<datafield tag="856" ind1="4" ind2="2">
					<subfield code="u">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="y">Data</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Series and location information for articles in 773.
				Journal name in $t
				Create volume:issue>start-end string for $q.
				Include Journal’s ISSN in $x.
				Unclear what to do with non article partofseries and whether they appear.
			-->
			<xsl:choose>
				<xsl:when test="$type = 'article' and dc:relation.ispartofseries">
					<datafield tag="773" ind1="4" ind2=" ">
						<subfield code="t">
							<xsl:value-of select="dc:bibliographicCitation.journal"/>
						</subfield>
						<xsl:if test="dc:bibliographicCitation.volume | dc:bibliographicCitation.firstPage">
							<subfield code="q">
								<xsl:if test="dc:bibliographicCitation.volume">
									<xsl:value-of select="dc:bibliographicCitation.volume[1]"/>
									<xsl:if test="dc:bibliographicCitation.issue">
										<xsl:text>:</xsl:text>
										<xsl:value-of select="dc:bibliographicCitation.issue[1]"/>
										<xsl:if test="dc:bibliographicCitation.articlenumber">
											<xsl:text>:</xsl:text>
											<xsl:value-of select="dc:bibliographicCitation.articlenumber[1]"/>
										</xsl:if>
									</xsl:if>
								</xsl:if>
								<xsl:if test="dc:bibliographicCitation.firstPage">
									<xsl:text>&gt;</xsl:text>
									<xsl:value-of select="dc:bibliographicCitation.firstPage[1]"/>
									<xsl:if test="dc:bibliographicCitation.lastPage">
										<xsl:text>-</xsl:text>
										<xsl:value-of select="dc:bibliographicCitation.lastPage[1]"/>
									</xsl:if>
								</xsl:if>
							</subfield>
						</xsl:if>
						<xsl:for-each select="dc:relation.issn | dc:relation.pISSN | dc:relation.eISSN">
							<xsl:if test="position() = 1">
								<subfield code="x">
									<xsl:value-of select="."/>
								</subfield>
							</xsl:if>
						</xsl:for-each>
					</datafield>
				</xsl:when>
				<xsl:otherwise>
					<!-- What to do in this case? When does it occur? Use 490? -->
				</xsl:otherwise>
			</xsl:choose>





			<!-- DESCRIPTION AND NOTES -->


			<!--
				Abstract goes to 520 with i1 = 3.
				We lose language information here.
			-->
			<xsl:for-each select="dc:description.abstract | dc:description.abstractger | dc:description.abstracteng">
				<datafield tag="520" ind1="3" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Table of Contents goes to 505 (Formatted Contents Note).
				ind1 = 0 for Complete Contents
			-->
			<xsl:for-each select="dc:description.tableofcontents">
				<datafield tag="505" ind1="0" ind2=" ">
					<subfield code="a">
						<xsl:call-template name="replace-separators">
							<xsl:with-param name="list" select="."/>
							<xsl:with-param name="separator-old">;</xsl:with-param>
							<xsl:with-param name="separator-new"> -- </xsl:with-param>
						</xsl:call-template>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Sponsorship goes to 536 (Funding Information Note).
			-->
			<xsl:for-each select="dc:description.sponsorship | dc:relation.euproject | dc:relation.eusponsor">
				<datafield tag="536" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Unqualified description or note goes to 500 (General Note).
			-->
			<xsl:for-each select="dc:description | dc:note">
				<datafield tag="500" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				DRIVER types to 562 $c (Version Information).
				DRIVER types: They express the publication’s state as one of
					* draft
					* submittedVersion
					* acceptedVersion
					* publishedVersion
					* updated
				Is there a better field than a comment?
			-->
			<xsl:for-each select="dc:type.version">
				<datafield tag="562" ind1=" " ind2=" ">
					<subfield code="c">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Rights descriptions and URIs go to 542 (Information Relating to Copyright Status).
				Rights holder to $c (Corporate creator). We don’t know whether the creator is a person or not. $c is not repeatable.
				URI to $u.
				General rights field to $n (Note).
				Map all into a single 542 field. (There should be at most a single one of these.)
				Would another field, e.g. 540 (Terms Governing Use and Reproduction Note) be more appropriate?
			-->
			<xsl:if test="dc:rights or dc:rights.access or dc:rights.uri or dc:rights.holder">
				<datafield tag="542" ind1=" " ind2=" ">
					<xsl:if test="dc:rights.holder">
						<subfield code="c">
							<xsl:for-each select="dc:rights.holder">
								<xsl:if test="position() != 1">
									<xsl:text>, </xsl:text>
								</xsl:if>
								<xsl:value-of select="."/>
							</xsl:for-each>
						</subfield>
					</xsl:if>
					<xsl:for-each select="dc:rights.uri">
						<subfield code="u">
							<xsl:value-of select="."/>
						</subfield>
					</xsl:for-each>
					<xsl:for-each select="dc:rights | dc:rights.access">
						<subfield code="n">
							<xsl:value-of select="."/>
						</subfield>
					</xsl:for-each>
				</datafield>
			</xsl:if>




			<!-- CLASSIFICATION AND SUBJECT INFORMATION -->


			<!--
				DDC goes to 082.
				Mark DNB Sachgruppen with ind2=9 (like GBV’s MARC export does).
			-->
			<xsl:for-each select="dc:subject.ddc">
				<datafield tag="082" ind1="0" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="dc:subject.dnb">
				<datafield tag="082" ind1="0" ind2="9">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				BK goes to 084 with $2 bcl.
			-->
			<xsl:for-each select="dc:subject.bk | dc:subject.gbv">
				<datafield tag="084" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">bcl</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				MSC goes to 084 with $2 msc.
			-->
			<xsl:for-each select="dc:subject.msc">
				<datafield tag="084" ind1=" " ind2="2">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">msc</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				BIC goes to 084 with $2 bic.
			-->
			<xsl:for-each select="dc:subject.bic">
				<datafield tag="084" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">bic</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				GOK goes to 084 with $2 gok.
				If we have identical numbers of subject.gokcode and subject.gokverbal,
				add the verbalistion to $9. (In analogy to GBV’s handling of BKL.)
				Otherwise just map the codes to 084 and the verbalisations to 653.
			-->
			<xsl:if test="dc:subject.gokcode or dc:subject.gokverbal">
				<xsl:choose>
					<xsl:when test="count(dc:subject.gokcode) = count(dc:subject.gokverbal)">
						<xsl:for-each select="dc:subject.gokcode">
							<xsl:variable name="position" select="position()"/>
							<datafield tag="084" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:value-of select="."/>
								</subfield>
								<subfield code="9">
									<xsl:value-of select="dc:subject.gokverbal[$position]"/>
								</subfield>
								<subfield code="2">gok</subfield>
							</datafield>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="dc:subject.gokcode">
							<datafield tag="084" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:value-of select="."/>
								</subfield>
								<subfield code="2">gok</subfield>
							</datafield>
						</xsl:for-each>
						<xsl:for-each select="dc:subject.gokverbal">
							<datafield tag="653" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:value-of select="."/>
								</subfield>
							</datafield>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>


			<!--
				SWD keywords go to 650 (Subject Added Entry-Topical Term), with ind2=7 and $2 swd.
			-->
			<xsl:for-each select="dc:subject.swd">
				<datafield tag="650" ind1=" " ind2="7">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">swd</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				MeSH goes to 650 (Subject Added Entry-Topical Term) with ind2=2.
			-->
			<xsl:for-each select="dc:subject.mesh">
				<datafield tag="650" ind1=" " ind2="2">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Subject goes to 653 (Index Term - Uncontrolled).
			-->
			<xsl:for-each select="dc:subject | dc:subject.topic | dc:subject.ger | dc:subject.eng | dc:subject.other | dc:subject.free">
				<datafield tag="653" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>




			<!-- IDENTIFIERS -->


			<!--
				ISBN goes to 020.
				Strip potential dashes.
			-->
			<xsl:for-each select="dc:identifier.isbn | dc:relation.isbn | dc:identifier.pISBN | dc:identifier.eISBN | dc:source.isbn">
				<datafield tag="020" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="translate(., '-', '')"/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				ISSN goes to 022.
				Do not strip dashes.
			-->
			<xsl:for-each select="dc:identifier.issn">
				<datafield tag="022" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				URN goes to 024 with $2 urn.
			-->
			<xsl:for-each select="dc:identifier.urn">
				<datafield tag="024" ind1="7" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">urn</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				DOI goes to 024 with $2 doi.
			-->
			<xsl:for-each select="dc:identifier.doi | dc:relation.doi">
				<datafield tag="024" ind1="7" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">doi</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				FactScience ID goes to 024 with $2 factscience.
				(Internal Uni Göttingen database for scientific publications)
			-->
			<xsl:for-each select="dc:identifier.fs">
				<datafield tag="024" ind1="7" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">factscience</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				PubMed ID goes to 024 with $2 pubmed.
			-->
			<xsl:for-each select="dc:identifier.pmid">
				<datafield tag="024" ind1="7" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">pubmed</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				PPN goes to 035.
				Prepend SUB Göttingen Sigel.
			-->
			<xsl:for-each select="dc:identifier.ppn">
				<datafield tag="035" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:text>(DE-7)</xsl:text>
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

		</record>
	</xsl:template>



	<!--
		Template to replace separator strings by other ones.
	-->
	<xsl:template name="replace-separators">
		<xsl:param name="list"/>
		<xsl:param name="separator-old"/>
		<xsl:param name="separator-new"/>

		<xsl:variable name="firstItem">
			<xsl:choose>
				<xsl:when test="contains($list, $separator-old)">
					<xsl:value-of select="normalize-space(substring-before($list, $separator-old))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$list"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="remainingItems" select="normalize-space(substring-after($list, $separator-old))"/>

		<xsl:if test="$firstItem">
			<xsl:value-of select="$firstItem"/>
		</xsl:if>

		<xsl:if test="$remainingItems">
			<xsl:value-of select="$separator-new"/>
			<xsl:call-template name="replace-separators">
				<xsl:with-param name="list" select="$remainingItems"/>
				<xsl:with-param name="separator-old" select="$separator-old"/>
				<xsl:with-param name="separator-new" select="$separator-new"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>