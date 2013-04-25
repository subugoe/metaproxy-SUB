<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:srw="http://www.loc.gov/zing/srw/" xmlns:zr="http://explain.z3950.org/dtd/2.0/" xmlns:diag="http://www.loc.gov/zing/srw/diagnostic/" xmlns:mg="info:srw/extension/5/metadata-grouping-v1.0" version="1.0">
  <!--      Author: Rob Sanderson (azaroth@liv.ac.uk)
           Version:  0.6
      Last Updated:  27/11/2003
           Licence:  GPL
           
 	  2013: Adapted for sru.sub.uni-goettingen.de by Sven-S. Porst <porst@sub.uni-goettingen.de>          
  -->
  <xsl:output method="xml" indent="yes"/>


  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
   
  <xsl:template match="/srw:explainResponse">
    <html>
      <head>
        <title>
          <xsl:value-of select="srw:record/srw:recordData/zr:explain/zr:databaseInfo/zr:title"/>
          <xsl:text> SRU Server</xsl:text>
        </title>

        <script type="text/javascript">
	      <xsl:text>
            var mungeForm = function () {
              var inform = document.getElementById('CQLForm');
              var outform = document.getElementById('SRUForm');
              var max = parseInt(inform.maxIndex.value);
              var cql = "";
              var prevIdx = 0;
              // Step through elements in form to create CQL
              for (var idx = 1; idx != max+1; idx++) {
                var term = inform["term"+idx].value;
                if (term) {
                  if (prevIdx) {
                    cql += " " + inform["bool" + prevIdx].value + " ";
                  }
                  if (term.indexOf(' ')) {
                    term = '"' + term + '"';
                  }
                  cql += inform["index" + idx].value + " " + inform["relat" + idx].value + " " + term;
                  prevIdx = idx;
                }
              }

              if (!cql) {
                alert("At least one term is required to search.");
                return false;
              }
              
              outform.query.value = cql;
              outform.submit();
              return false;
            }
	      </xsl:text>
        </script>


        <style type="text/css">
          <xsl:text>
          h2 {font-family: sans-serif; color: #FF5500; background-color: #eeeeff; padding-top: 10px; padding-bottom: 10px; border: 1px solid #3333FF}
          h3 { font-family: sans-serif; color: #F65500; text-indent: 20px; border-left: solid 1px #3333FF; border-top: solid 1px #3333FF; padding-top: 5px }
          .paramTable { vertical-align: top; background: #efefef; padding: 3px; border-collapse: collapse }
          .exampleTable { vertical-align: top; border: 1px solid; padding: 3px; border-collapse: collapse; background-color: #eeeeff}
          .paramTable td {border: 1px solid}
          .exampleTable td {border: 1px solid}
          th {border: 1px solid; background-color: #eeeeff}
          .indexName { font-weight: bold; }
          .indexID { color: #999; margin-left: 0.5em; }
          </xsl:text>
        </style>

         
        </head>
      <body>
        <h2>
          <xsl:value-of select="srw:record/srw:recordData/zr:explain/zr:databaseInfo/zr:title"/>
          <xsl:text> SRU interface</xsl:text>
        </h2>
        <p>
          <xsl:value-of select="srw:record/srw:recordData/zr:explain/zr:databaseInfo/zr:description"/>
        </p>
        <xsl:apply-templates select="/srw:explainResponse/diag:diagnostics"/>
        <table width="100%" cellspacing="5">
          <tr>
            <td>
              <p>
                <form name="CQLForm" id="CQLForm" onsubmit="return mungeForm();">
                  <input type="submit" value="Search"/>
                  <table class="paramTable">
                    <tr>
                      <th>Index</th>
                      <th>Relation</th>
                      <th>Term</th>
                      <th>Boolean</th>
                    </tr>
                    <input type="hidden" name="maxIndex">
                      <xsl:attribute name="value">
                        <xsl:value-of select="count(srw:record/srw:recordData/zr:explain/zr:indexInfo/zr:index)"/>
                      </xsl:attribute>
                    </input>
                    <xsl:for-each select="srw:record/srw:recordData/zr:explain/zr:indexInfo/zr:index">
                      <xsl:sort select="."/>
                      <tr>
                        <td>
                          <span class="indexName">
                            <xsl:value-of select="zr:title"/>
                          </span>
                          <span class="indexID"><xsl:value-of select="zr:map[1]/zr:name/@set"/>.<xsl:value-of select="zr:map[1]/zr:name"/></span>
                          <input type="hidden">
                            <xsl:attribute name="name">index<xsl:value-of select="position()"/></xsl:attribute>
                            <xsl:attribute name="value"><xsl:value-of select="zr:map[1]/zr:name/@set"/>.<xsl:value-of select="zr:map[1]/zr:name"/></xsl:attribute>
                          </input>
                        </td>
                        <td>
                          <select>
                            <xsl:attribute name="name">relat<xsl:value-of select="position()"/></xsl:attribute>
                            <option value="=">=</option>
                            <option value="exact">exact</option>
                            <option value="any">any</option>
                            <option value="all">all</option>
                            <option value="&lt;">&lt;</option>
                            <option value="&gt;">&gt;</option>
                            <option value="&lt;=">&lt;=</option>
                            <option value="&gt;=">&gt;=</option>
                            <option value="&lt;&gt;">not</option>
                          </select>
                        </td>
                        <td>
                          <input type="text" value="">
                            <xsl:attribute name="name">term<xsl:value-of select="position()"/></xsl:attribute>
                          </input>
                        </td>
                        <td>
                          <select>
                            <xsl:attribute name="name">bool<xsl:value-of select="position()"/></xsl:attribute>
                            <option value="and">and</option>
                            <option value="or">or</option>
                            <option value="not">not</option>
                          </select>
                        </td>
                      </tr>
                    </xsl:for-each>
                  </table>
                </form>
                
                
                <form method="GET" name="SRUForm" id="SRUForm" onsubmit="return mungeForm();">
                  <input type="hidden" name="query" value=""/>
                  <input type="hidden" name="version">
                    <xsl:attribute name="value">
                      <xsl:value-of select="srw:version"/>
                    </xsl:attribute>
                  </input>
                  <input type="hidden" name="operation" value="searchRetrieve"/>
                  <table>
                    <tr>
                      <td>
                        <b>Record Schema:</b>
                      </td>
                      <td>
                        <select name="recordSchema">
                          <xsl:for-each select="srw:record/srw:recordData/zr:explain/zr:schemaInfo/zr:schema">
                            <option>
                              <xsl:attribute name="value">
                                <xsl:value-of select="@name"/>
                              </xsl:attribute>
                              <xsl:value-of select="zr:title"/>
                            </option>
                          </xsl:for-each>
                        </select>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <b>Record Position:</b>
                      </td>
                      <td>
                        <input type="text" name="startRecord" value="1"/>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <b>Number of Records:</b>
                      </td>
                      <td>
                        <input type="text" name="maximumRecords">
                          <xsl:attribute name="value">
                            <xsl:choose>
                              <xsl:when test="srw:record/srw:recordData/zr:explain/zr:configInfo/zr:default[@type=&quot;numberOfRecords&quot;]">
                                <xsl:value-of select="srw:record/srw:recordData/zr:explain/zr:configInfo/zr:default[@type=&quot;numberOfRecords&quot;]"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:text>20</xsl:text>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:attribute>
                        </input>
                      </td>
                    </tr>
                  </table>
                  <input type="submit" value="Search"/>
                </form>
              </p>
            </td>
          </tr>
        </table>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="/srw:explainResponse/diag:diagnostics">
    <table>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  <xsl:template match="diag:message">
    <tr>
      <td>
        <b>Message:</b>
      </td>
      <td>
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match="diag:details">
    <tr>
      <td>
        <b>Details:</b>
      </td>
      <td>
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match="diag:uri">
    <xsl:if test="../diag:message">
      <tr>
        <td>
          <b>Identifier:</b>
        </td>
        <td>
          <xsl:value-of select="."/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="diag:details">
    <tr>
      <td>
        <b>Details:</b>
      </td>
      <td>
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match="diag:message">
    <tr>
      <td>
        <b>Message:</b>
      </td>
      <td>
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
