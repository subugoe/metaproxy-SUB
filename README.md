# metaproxy-SUB
Metaproxy configuration for SUB Göttingen.

2012 by Sven-S. Porst, [SUB Göttingen](http://www.sub.uni-goettingen.de/) <[porst@sub.uni-goettingen.de](porst@sub.uni-goettingen.de)>.


## subfolders
* config: configuration files
	* SUB.xml: main configuration file for the service
	* create-explains.py: script to create explain responsed from the SUB.xml configuration; uses the xsl/zoom-to-explains.xsl and explains-to-srufilter.xsl stylesheets
	* explain: folder with explain responses; its content is generated by the create-explains.py script
		* explains.xml: type `sru_z3950` filter tag with explain responses for all databases; loaded into SUB.xml with XInclude
		* $DATABASE.xml: for each database $DATABASE the explain response 
* init.d: metaproxy init script for SLES
* xsl: stylesheets used by the configuration
	* dspace-solr-to-dc: convert Solr documents from DSpace to the extended DC-format used by DSpace’s (unreliable) SRU interface add-on
	* explains-to-srufilter.xsl, zoom-to-explains.xsl: Stylesheets used by config/create-explains.py
	* test: example records to test stylesheets on


## submodules
[Index Data](http://www.indexdata.com/) libraries and code to build metaproxy:
* yaz: [yaz library](http://www.indexdata.com/yaz)
* yazpp: [yaz++ C++ API for yaz](http://www.indexdata.com/yazpp)
