#!/usr/bin/env python
#coding=utf-8
"""
Script to create SRU explain response setup from a Metaproxy configuration
file with a zoom filter.

2012 Sven-S. Porst <porst@sub.uni-goettingen.de>
"""
import sys
from lxml import etree

filename = sys.argv[1]

xslXML = etree.parse("../xsl/explains/zoom-to-explains.xsl")
xsl = etree.XSLT(xslXML)

configXML = etree.parse(filename)
explainXML = xsl(configXML, **{"hostname":"sru.sub.uni-goettingen.de", "port":"80"})
explains = explainXML.xpath("//explains/e:explain",
							namespaces = {"e": "http://explain.z3950.org/dtd/2.0/"})

for explain in explains:
	databaseNames = explain.xpath("e:serverInfo/e:database",
									namespaces = {"e": "http://explain.z3950.org/dtd/2.0/"})
	if len(databaseNames) > 0:
		databaseName = databaseNames[0].text
		filePath = "explain/" + databaseName.replace("/", "_") + ".xml"
		explainFile = open (filePath, "w")
		explainFile.write(etree.tostring(explain, encoding="utf-8", pretty_print=True))
		explainFile.close()
		print u"wrote »" + filePath + u"«"


xslXML = etree.parse("../xsl/explains/explains-to-srufilter.xsl")
xsl = etree.XSLT(xslXML)
sruFilter = xsl(explainXML)

sruFilter.write("explain/explains.xml", encoding="utf-8", pretty_print=True)
print u"wrote »explain/explains.xml« for XInclude"
