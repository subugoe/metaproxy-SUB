<?xml version="1.0" encoding="UTF-8"?>
<!--
	Stylesheet for converting DSpace DC data to MARC records.
	Our DSpace systems provide fields beyond the standard DC, try to accomotate those.

	Overview of fields used by DSpace (not publicly accessible):
		https://docs.google.com/spreadsheet/ccc?key=0AnYBqnG_KlOjdHc5R2h4ZlpSenp0d3RDZVhBYXZjR0E

	2012-2013 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
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

			<!-- position 5: record status: c (changed) - even if it could be new as we can’t tell the difference -->
			<xsl:variable name="leader05">c</xsl:variable>
			
			<!-- position 6: type of record: a (language material) -->
			<xsl:variable name="leader06">a</xsl:variable>
			
			<!-- position 7: bibliographic level -->
			<xsl:variable name="leader07">
				<xsl:choose>
					<!-- monographic component part -->
					<xsl:when test="$type='article'">a</xsl:when>
					<xsl:when test="$type='bookPart'">a</xsl:when>
					<xsl:when test="$type='contributionToPeriodial'">a</xsl:when>
					<xsl:when test="$type='preprint'">a</xsl:when>
					<xsl:when test="$type='review'">a</xsl:when>
					<xsl:when test="$type='wrokingPaper'">a</xsl:when>
					<!-- collection -->
					<xsl:when test="$type='collection'">c</xsl:when>
					<!-- monograph -->
					<xsl:otherwise>m</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<leader>
				<xsl:value-of select="concat('     ', $leader05, $leader06, $leader07, ' a22     3u 4500')"/>
			</leader>


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
			
			<!-- position 6-14: use description.date (letters) or date.issued at the precision that is available -->
			<xsl:variable name="publicationDate">
				<xsl:choose>
					<xsl:when test="string-length(dc:description.date) &gt; 3">
						<xsl:value-of select="dc:description.date"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="dc:date.issued"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- Date Precision coded as s, e or blank. -->
			<xsl:variable name="datefields">
				<xsl:choose>
					<xsl:when test="string-length($publicationDate) &gt; 6">
						<xsl:text>e</xsl:text>
						<xsl:value-of select="substring($publicationDate, 1, 4)"/>
						<xsl:value-of select="substring($publicationDate, 6, 2)"/>
						<xsl:choose>
							<xsl:when test="string-length($publicationDate) &gt; 9">
								<xsl:value-of select="substring($publicationDate, 9, 2)"/>
							</xsl:when>
							<xsl:otherwise>uu</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="string-length($publicationDate) &gt; 3">
						<xsl:text>s</xsl:text>
						<xsl:value-of select="substring($publicationDate, 1, 4)"/>
						<xsl:text>    </xsl:text>
					</xsl:when>
					<xsl:otherwise>         </xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- position 15-17: unknown -->
			<xsl:variable name="place">
				<xsl:text>xx </xsl:text>
			</xsl:variable>
			
			<!-- position 18-34 for type book:
				 18-21: blank (illustrations)
				 22: f (target audience: specialised)
				 23: o (form of item: online resource)
				 24-27: depending on type: [jmot2](nature of contents)
				 28: blank (government publication)
				 29: [1 ] (conference publication)
				 30: blank (festschrift)
				 31: blank (index)
				 32: blank (undefined)
				 33: [i ] (literary form)
				 34: blank (biography)
			-->
			<xsl:variable name="illustrations"><xsl:text>    </xsl:text></xsl:variable>
			<xsl:variable name="targetAudience">f</xsl:variable>
			<xsl:variable name="formOfItem">o</xsl:variable>
			<xsl:variable name="natureOfContents">
				<xsl:choose>
					<xsl:when test="dc:type='bachelorThesis' or dc:type='masterThesis'
								 or dc:type='doctoralThesis' or dc:type='magisterThesis'
								 or dc:type='cumulativeThesis'">m</xsl:when>
					<xsl:when test="dc:type='patent'">j</xsl:when>
					<xsl:when test="dc:type='review'">o</xsl:when>
					<xsl:when test="dc:type='preprint' or dc:type='workingPaper'">2</xsl:when>
					<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
				</xsl:choose>
				<xsl:text>   </xsl:text>
			</xsl:variable>
			<xsl:variable name="governmentPublication"><xsl:text> </xsl:text></xsl:variable>
			<xsl:variable name="conferencePublication">
				<xsl:choose>
					<xsl:when test="dc:type='conferenceObject' or dc:contributor.meeting">1</xsl:when>
					<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="festschrift"><xsl:text> </xsl:text></xsl:variable>
			<xsl:variable name="index"><xsl:text> </xsl:text></xsl:variable>
			<xsl:variable name="literaryForm">
				<xsl:choose>
					<!-- preliminary / DSpace field likely to change -->
					<xsl:when test="dc:type.subtype='letter' or dc:type.subtype='letters'">i</xsl:when>
					<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="biography"><xsl:text> </xsl:text></xsl:variable>
			
			<xsl:variable name="typespecific">
				<xsl:value-of select="$illustrations"/> <!-- 18-21 -->
				<xsl:value-of select="$targetAudience"/> <!-- 22 -->
				<xsl:value-of select="$formOfItem"/> <!-- 23 -->
				<xsl:value-of select="$natureOfContents"/> <!-- 24-27 -->
				<xsl:value-of select="$governmentPublication"/> <!-- 28 -->
				<xsl:value-of select="$conferencePublication"/> <!-- 29 -->
				<xsl:value-of select="$festschrift"/> <!-- 30 -->
				<xsl:value-of select="$index"/> <!-- 31 -->
				<xsl:text> </xsl:text> <!-- 32: undefined -->
				<xsl:value-of select="$literaryForm"/> <!-- 33 -->
				<xsl:value-of select="$biography"/> <!-- 34 -->
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

			<controlfield tag="008">
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
				Place of birth information is omitted.
			-->
			<xsl:for-each select="dc:contributor.author | dc:contributor.editor |
									dc:contributor.corporation | dc:contributor.meeting |
									dc:contributor.sender | dc:contributor.senderCorporation |
									dc:contributor.recipient | dc:contributor.recipientCorporation |
									dc:contributor.advisor | dc:contributor.other | dc:contributor.illustrator |
									dc:contributor.referee | dc:contributor.coReferee | dc:contributor.thirdReferee
									">
				
				<datafield ind1="1" ind2=" ">
					<!--
						Field 7XX. TODO: figure out how to determine who gets the 1XX spot.
						Field X00, X10, or X11 depending on the field name:
							X10 if it contains [Cc]orporation
							X11 if it contains meeting
							X00 otherwise
					-->
					<xsl:variable name="fieldNumber">
						<xsl:choose>
							<xsl:when test="(count(../dc:contributor.author) + count(../dc:contributor.editor)
										+ count(../dc:contributor.sender) + count(../dc:contributor.meeting) 
										+ count(../dc:contributor.corporation) = 1) and
										(local-name()='contributor.author' or local-name()='contributor.editor'
										or local-name()='contributor.sender' or local-name()='contributor.meeting'
										or local-name()='contributor.corporation')">1</xsl:when>
							<xsl:otherwise>7</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="contains(local-name(), 'orporation')">10</xsl:when>
							<xsl:when test="contains(local-name(), 'meeting')">11</xsl:when>
							<xsl:otherwise>00</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:attribute name="tag">
						<xsl:value-of select="$fieldNumber"/>
					</xsl:attribute>
					
					<!--
						ind1:
						2 for corporations and mettings
						1 otherwise
					-->
					<xsl:attribute name="ind1">
						<xsl:choose>
							<xsl:when test="substring($fieldNumber, 2, 1) = '1'">2</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					
					<!-- Name -->
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					
					<!-- Person role(s) -->
					<xsl:choose>
						<xsl:when test="local-name()='contributor.author' or local-name()='contributor.sender'">
							<subfield code="4">aut</subfield>
						</xsl:when>
						<xsl:when test="local-name()='contributor.sender'">
							<subfield code="4">cor</subfield>
						</xsl:when>
						<xsl:when test="local-name()='contributor.editor'">
							<subfield code="4">edt</subfield>
						</xsl:when>
						<xsl:when test="local-name()='contributor.illustrator'">
							<subfield code="4">ill</subfield>
						</xsl:when>
						<xsl:when test="contains(local-name(), 'recipient')">
							<subfield code="4">rcp</subfield>
						</xsl:when>
						<xsl:when test="local-name()='contributor.advisor'">
							<subfield code="4">ths</subfield>
						</xsl:when>
						<xsl:when test="local-name()='contributor.referee' or local-name()='contributor.coReferee'
											or local-name()='contributor.thirdReferee'">
							<subfield code="4">rev</subfield>
						</xsl:when>

					</xsl:choose>		
					
					<!-- Additional role for senders of letters. -->
					<xsl:if test="local-name() = 'contributor.sender'">
						<subfield code="4">cor</subfield>
					</xsl:if>

					<!-- University department information for dissertatipm authors -->
					<xsl:if test="local-name() = 'contributor.author'">
						<xsl:if test="../dc:affiliation.institut">
							<subfield code="u">
								<xsl:for-each select="../dc:affiliation.institut[1]">
									<xsl:value-of select="."/>
								</xsl:for-each>
							</subfield>
						</xsl:if>
					</xsl:if>		
				</datafield>
			</xsl:for-each>
			

			
			<!--
				Letter Recipients go to 700/710 with $4 rcp (Recipient).
			-->			
			<xsl:for-each select="dc:contributor.recipientCorporation">
				<datafield tag="710" ind1="1" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="4">rcp</subfield>
				</datafield>
			</xsl:for-each>




			<!-- TITLE -->

			<!--
				Title goes to 245 $a.
				Subtitle, translated title and translated subtitle go to $b
					with funny librarian characters in between.
			-->
			<xsl:if test="dc:title">
				<datafield tag="245" ind1="0" ind2="0">
					<subfield code="a">
						<xsl:value-of select="dc:title"/>
						<xsl:choose>
							<xsl:when test="dc:title.alternative">
								<xsl:text> :</xsl:text>
							</xsl:when>
							<xsl:when test="dc:title.translated">
								<xsl:text> =</xsl:text>
							</xsl:when>
						</xsl:choose>
					</subfield>
					<xsl:if test="dc:title.alternative or dc:title.translated">
						<subfield code="b">
							<xsl:if test="dc:title.alternative">
								<xsl:value-of select="dc:title.alternative"/>
							</xsl:if>
							<xsl:for-each select="dc:title.translated">
								<xsl:variable name="position">
									<xsl:value-of select="position()"/>
								</xsl:variable>
								<xsl:if test="../dc:title.alternative or $position!=1">
									<xsl:text> = </xsl:text>
								</xsl:if>
								<xsl:value-of select="."/>
								<xsl:if test="../dc:title.alternativeTranslated[position()=$position]">
									<xsl:text> : </xsl:text>
									<xsl:value-of select="../dc:title.alternativeTranslated[position()=$position]"/>
								</xsl:if>
							</xsl:for-each>
						</subfield>
					</xsl:if>
					<xsl:if test="dc:description.statementofresponsibility">
						<subfield code="c">
							<xsl:value-of select="dc:description.statementofresponsibility"/>
						</subfield>
					</xsl:if>
				</datafield>
			</xsl:if>




			<!-- PUBLISHING AND ACCESS -->


			<!--
				Information about the first publication goes to 775 $d.
			-->
			<xsl:if test="dc:publisher">
				<datafield tag="775" ind1=" " ind2=" ">
					<xsl:if test="dc:title">
						<subfield code="t">
							<xsl:value-of select="dc:title"/>
						</subfield>
					</xsl:if>
					<subfield code="d">
						<xsl:value-of select="dc:publisher"/>
						<xsl:if test="dc:publisher.place">
							<xsl:text>, </xsl:text>
							<xsl:value-of select="dc:publisher.place"/>
						</xsl:if>
						<xsl:if test="dc:date.issued">
							<xsl:text>, </xsl:text>
							<xsl:value-of select="dc:date.issued"/>
						</xsl:if>											
					</subfield>
				</datafield>
			</xsl:if>
			
			
			<!--
				Location of publication goes to 260 $e.
				Used for letters.				
			-->
			<xsl:for-each select="dc:description.location">
				<datafield tag="260" ind1=" " ind2=" ">
					<subfield code="e">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


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
				URI of part goes to 856 $u with note »Part« in $3.
			-->
			<xsl:for-each select="dc:relation.haspart">
				<datafield tag="856" ind1="4" ind2="2">
					<subfield code="u">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="3">Part</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				URI of related data goes to 856 $u with »Data« note in $3 and ind2=2.
			-->
			<xsl:for-each select="dc:relation.isbasedon">
				<datafield tag="856" ind1="4" ind2="2">
					<subfield code="u">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="3">Data</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				URI of other version goes to 856 $u with »Other Version« note in $3 and ind2=1.
			-->
			<xsl:for-each select="dc:relation.hasversion">
				<datafield tag="856" ind1="4" ind2="1">
					<subfield code="u">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="3">Other Version</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				URI of referencing item goes to 856 $u with »Referenced By« note in $3 and ind2=1.
			-->
			<xsl:for-each select="dc:relation.isreferencedby">
				<datafield tag="856" ind1="4" ind2="1">
					<subfield code="u">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="3">Referenced by</subfield>
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
					<subfield code="y">METS</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				Series and location information for articles in 773.
				Journal name in $t
				Create volume:issue>start-end string for $q.
				Include containing journal/book’s ISSN/ISBN in $x/$z.
				TODO: Unclear what to do with non article partofseries and whether they appear.
				TODO: Title of containing book for articles?
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
						<xsl:for-each select="dc:relation.isbn | dc:relation.pISBN | dc:relation.eISBN">
							<subfield code="z">
								<xsl:value-of select="translate(., '-', '')"/>
							</subfield>						
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
				Replace line breaks with pilcrow signs to transport the paragraph endings (line
					breaks are forbidden by MARC).
			-->
			<xsl:for-each select="dc:description.abstract | dc:description.abstractger | dc:description.abstracteng">
				<datafield tag="520" ind1="3" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="translate(., '&#xa;', '&#xb6;')"/>
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
				Regest goes to 520 (Summary, Etc.) with free text label 'Res gestae'.
			-->
			<xsl:for-each select="dc:description.regest | dc:description.partregest">
				<datafield tag="520" ind1=" " ind2="8">
					<subfield code="a">
						<xsl:text>Res gestae: </xsl:text>
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				URI pointing to description goes to 520 (Summary, Etc.) $u.
			-->
			<xsl:for-each select="dc:description.uri">
				<datafield tag="520" ind1=" " ind2=" ">
					<subfield code="u">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			
			<!--
				Information about the source the metadata came from goes to 588 $a (Source of Description Note).
				(Gauß Letters)
			-->
			<xsl:for-each select="dc:description.source">
				<datafield tag="588" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			
			<!--
				Shelf mark of the original version goes to 534 (Original Version Note) $l
					 preceded by »Original:« in $p.
			-->
			<xsl:for-each select="dc:description.source">
				<datafield tag="534" ind1=" " ind2=" ">
					<subfield code="p">Original:</subfield>
					<subfield code="l">
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


			<!--
				Copyright Date goes to 264 $c with ind2=4 (Copyright Notice Date).
			-->
			<xsl:for-each select="dc:type.copyright">
				<datafield tag="264" ind1=" " ind2="4">
					<subfield code="c">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>




			<!-- CLASSIFICATION AND SUBJECT INFORMATION -->


			<!--
				DDC goes to 082.
			-->
			<xsl:for-each select="dc:subject.ddc">
				<datafield tag="082" ind1="0" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				BK (Basisklassifikation) goes to 084 with $2 bcl.
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
				MSC (Mathematics Subject Classification) goes to 084 with $2 msc.
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
				KISS (Kieler Sacherschließungssystem) goes to 084 with $2 kiss.
			-->
			<xsl:for-each select="dc:subject.kiss">
				<datafield tag="084" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">kiss</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				GOK (Göttinger Online Klassifikation) goes to 084 with $2 gok.
				If we have identical numbers of subject.gokcode and subject.gokverbal,
				add the verbalistion to $9. (In analogy to GBV’s handling of BKL.)
				Otherwise just map the codes to 084 and the verbalisations to 653.
			-->
			<xsl:if test="dc:subject.gok or dc:subject.gokverbal">
				<xsl:choose>
					<xsl:when test="count(dc:subject.gok) = count(dc:subject.gokverbal)">
						<xsl:for-each select="dc:subject.gok">
							<xsl:variable name="position" select="position()"/>
							<datafield tag="084" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:value-of select="."/>
								</subfield>
								<xsl:choose>
									<xsl:when test="contains(dc:subject.gokverbal, ' (PPN')">
										<subfield code="9">
											<xsl:value-of select="substring-before(dc:subject.gokverbal[position()=$position], ' (PPN')"/>
										</subfield>
										<subfield code="0">
											<xsl:value-of select="substring-before(substring-after(dc:subject.gokverbal[position()=$position], ' (PPN'), ')')"/>
										</subfield>
									</xsl:when>
									<xsl:otherwise>
										<subfield code="9">
											<xsl:value-of select="dc:subject.gokverbal"/>		
										</subfield>			
									</xsl:otherwise>
								</xsl:choose>
								<subfield code="2">gok</subfield>
							</datafield>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="dc:subject.gok">
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
				SWD keywords go to 650 (Subject Added Entry-Topical Term), with ind2=7 and $2 gnd.
			-->
			<xsl:for-each select="dc:subject.swd">
				<datafield tag="650" ind1=" " ind2="7">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">gnd</subfield>
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
			<xsl:for-each select="dc:identifier.isbn | dc:identifier.pISBN | dc:identifier.eISBN | dc:source.isbn">
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
				ISMN goes to 024 with i1 = 2.
			-->
			<xsl:for-each select="dc:identifier.ismn">
				<datafield tag="024" ind1="2" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>


			<!--
				SICI goes to 024 with i1 = 4.
			-->
			<xsl:for-each select="dc:identifier.sici">
				<datafield tag="024" ind1="4" ind2=" ">
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
				Prepend GBV Sigel.
			-->
			<xsl:for-each select="dc:identifier.ppn">
				<datafield tag="035" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:text>(DE-599)GBV</xsl:text>
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