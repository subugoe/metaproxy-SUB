<?xml version="1.0" encoding="UTF-8"?>
<!--
	Stylesheet to convert a Metaproxy configuration file into a HTML page.
	This is not comprehensive and only accounts for the Metaproxy options acutally used at SUB Göttingen.

	2012 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xi="http://www.w3.org/2001/XInclude"
		xmlns:mp="http://indexdata.com/metaproxy"
		xmlns:e="http://explain.z3950.org/dtd/2.0/"
		exclude-result-prefixes="mp">

	<xsl:output method="html"
				cdata-section-elements="style"
				indent="yes"
				encoding="utf-8"/>



	<!--
		Root node
		Create HTML page.
	-->
	<xsl:template match="/">
		<html>
			<xsl:call-template name="html-head"/>
			<body>
				<xsl:apply-templates select="mp:metaproxy"/>
			</body>
		</html>
	</xsl:template>


	<!--
		metaproxy Tag
		Evaluate start and routes tags.
		The filters tag is not used as filters will be included in the routes using them.
	-->
	<xsl:template match="mp:metaproxy">
		<h1>Metaproxy configuration</h1>

		<xsl:apply-templates select="mp:start"/>
		<xsl:apply-templates select="mp:routes"/>
	</xsl:template>


	<!--
		start Tag
		The Start Route
	-->
	<xsl:template match="mp:start">
		<h3>Start Route</h3>
		<p>
			<xsl:value-of select="@route"/>
		</p>
	</xsl:template>


	<!--
		routes Tag
		Output each route and mark the Start route.
		Process all filters including those loaded via XInclude.
	-->
	<xsl:template match="mp:routes">
		<xsl:variable name="startroute">
			<xsl:value-of select="../mp:start/@route"/>
		</xsl:variable>

		<h3>Routes</h3>

		<xsl:for-each select="mp:route">
			<h4 id="route-{@id}">
				<xsl:text>Route »</xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text>«</xsl:text>
				<xsl:if test="$startroute = @id">
					<xsl:text> (Start Route)</xsl:text>
				</xsl:if>
			</h4>

			<ol>
				<xsl:apply-templates select="mp:filter | xi:include"/>
			</ol>
		</xsl:for-each>

	</xsl:template>


	<!--
		XInclude
		Load XIncluded filters for routes.
	-->
	<xsl:template match="mp:route/xi:include">
		<xsl:apply-templates select="document(@href, .)/mp:filter"/>
	</xsl:template>


	<!--
		filter
		Output each filter, evaluating the refid attribute by replacing the filter tag with the referenced one.
		Filter ID and type go in the heading, all other attributes and tags follow.
		fieldmap tags are collected separately to be processed last.
	-->
	<xsl:template match="mp:filter">
		<xsl:choose>
			<xsl:when test="@refid">
				<xsl:variable name="refid" select="@refid"/>
				<xsl:apply-templates select="/mp:metaproxy/mp:filters/mp:filter[@id = $refid]"/>
			</xsl:when>
			<xsl:otherwise>
				<li>
					<span class="name">
						<xsl:value-of select="@type"/>
						<xsl:if test="@id">
							<xsl:text> (</xsl:text>
								<xsl:value-of select="@id"/>
							<xsl:text>)</xsl:text>
						</xsl:if>
					</span>
					<dl>
						<xsl:apply-templates select="@*[local-name() != 'type' and local-name != 'id']
													|*[local-name() != 'fieldmap']"/>
						<xsl:if test="mp:fieldmap">
							<dt>Fieldmap</dt>
							<dd>
								<ul>
									<xsl:apply-templates select="mp:fieldmap"/>
								</ul>
							</dd>
						</xsl:if>
					</dl>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!--
		filter attributes and child elements
		* list attributes
		* list child elements
			* list child element attributes
	-->
	<xsl:template match="mp:filter/@* | mp:filter/mp:*">
		<dt>
			<xsl:value-of select="local-name(.)"/>
		</dt>
		<dd>
			<xsl:value-of select="."/>
			<xsl:if test="./@*">
				<dl>
					<xsl:for-each select="./@*">
						<dt>
							<xsl:value-of select="local-name(.)"/>
						</dt>
						<dd>
							<xsl:value-of select="."/>
						</dd>
					</xsl:for-each>
				</dl>
			</xsl:if>
		</dd>
	</xsl:template>


	<!--
		database Tags for sru_z3950 filter
		These define the explain responses used by the SRU service.
		Display the database names and link the explain responses.
	-->
	<xsl:template match="mp:filter[@type='sru_z3950']/mp:database">
		<dt>
			<xsl:value-of select="@name"/>
		</dt>
		<dd>
			<xsl:variable name="address" select="concat('explain/', xi:include/@href)"/>
			<a>
				<xsl:attribute name="href">
					<xsl:value-of select="$address"/>
				</xsl:attribute>
				<xsl:value-of select="$address"/>
			</a>
		</dd>
	</xsl:template>


	<!--
		torus Tag for zoom filter
		Show attributes then show records.
	-->
	<xsl:template match="mp:filter[@type='zoom']/mp:torus">
		<dt>Torus</dt>
		<dd>
			<dl>
				<xsl:for-each select="@*">
					<dt>
						<xsl:value-of select="local-name(.)"/>
					</dt>
					<dd>
						<xsl:value-of select="."/>
					</dd>
				</xsl:for-each>

				<xsl:apply-templates select="mp:records/mp:record"/>
			</dl>
		</dd>
	</xsl:template>


	<!--
		record Tag in torus
		Show database path and name as a heading.
		Then show the remaining fields that are not cclmaps.
		Finally show the cclmaps in a »Search Keys« section.
	-->
	<xsl:template match="mp:record">
		<dt>
			<xsl:value-of select="mp:udb"/>
			<xsl:if test="e:databaseInfo/e:title">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="e:databaseInfo/e:title[1]"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</dt>
		<dd>
			<dl>
				<xsl:for-each select="*[substring(local-name(), 1, 7) != 'cclmap_'
										and local-name() != 'udb']">
					<dt>
						<xsl:value-of select="local-name()"/>
					</dt>
					<dd>
						<xsl:value-of select="."/>
					</dd>
				</xsl:for-each>
				<dt>
					Search Keys
					<span class="name">[SRU index name (internal CCL name):</span> yaz query settings]
				</dt>
				<dd>
					<ul>
						<xsl:apply-templates select="*[substring(local-name(), 1, 7) = 'cclmap_']"/>
					</ul>
				</dd>
			</dl>
		</dd>
	</xsl:template>


	<!--
		cclmap Tags
		Display each cclmap_XXX tag as »CQL Name (CCL Name): yaz-settings«.
		Use the fieldmap to get the cqlname.
	-->
	<xsl:template match="*[substring(local-name(), 1, 7) = 'cclmap_']">
		<xsl:variable name="name" select="substring(local-name(), 8)"/>
		<li>
			<span class="name">
				<xsl:value-of select="//mp:fieldmap[@ccl = $name]/@cql"/>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="$name"/>
				<xsl:text>): </xsl:text>
			</span>
			<xsl:value-of select="."/>
		</li>
	</xsl:template>


	<!--
		fieldmap Tags
		Display each fieldmap tag as »SRU CQL index name → cclname: Index description«.
	-->
	<xsl:template match="mp:filter[@type='zoom']/mp:fieldmap">
		<li>
			<xsl:value-of select="@cql"/>
			<xsl:text> → </xsl:text>
			<xsl:value-of select="@ccl"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="mp:title"/>
		</li>
	</xsl:template>



	<!--
		html <head>
		Inserted into web page.
	-->
	<xsl:template name="html-head">
		<head>
			<title>
				<xsl:text>Metaproxy configuration</xsl:text>
			</title>

			<style type="text/css">
				<![CDATA[
				body {
					font-family: Tahoma, sans-serif;
					background: #eee;
					color: #111;
					line-height: 140%;
				}
				h3 {
					clear: both;
					margin-top: 2em;
				}
				a {
					text-decoration: none;
				}
				dt {
					font-weight: bold;
				}
				dt:after {
					content: ':';
				}
				.name {
					font-weight: bold;
				}
				]]>
			</style>
		</head>
	</xsl:template>

</xsl:stylesheet>
