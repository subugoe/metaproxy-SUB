<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:srw="http://www.loc.gov/zing/srw/"
	xmlns:e="http://explain.z3950.org/dtd/2.0/"
	xmlns:diag="http://www.loc.gov/zing/srw/diagnostic/"
	xmlns:mp="http://indexdata.com/metaproxy"
	version="1.0">
  <!--
            Author: Rob Sanderson (azaroth@liv.ac.uk)
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
    <xsl:variable name="dbInfo" select="srw:record/srw:recordData/e:explain/e:databaseInfo[1]"/>
  
    <html>
      <head>
        <title>
          <xsl:value-of select="$dbInfo/e:title"/>
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
	          * { margin: 0; padding: 0; }
	          body { padding: 2em 4em; background: #efeeef; font-family: Helvetica, Arial, sans-serif; }
	          #head { margin-bottom: 2em; }
	          img.logo { float: right; }
	          h1 { font-size: 200%; margin: 0em 0 0.5em 0; }
	          p { margin-bottom: 1em; }
	          h3 { font-family: sans-serif; color: #F65500; text-indent: 20px; border-left: solid 1px #3333FF; border-top: solid 1px #3333FF; padding-top: 5px }
	          table.paramTable { margin: 1em 0; }
	          tr { }
	          th { padding: 2px; background-color: #666; color: #fff; text-align: left; }
	          .paramTable td.indexInfo { border-bottom: 1px #bbb solid; padding: 2px 10px 2px 2px;}
	          .indexName { font-weight: bold; }
	          .indexID { color: #999; margin-left: 0.3em; }
	          .setting { display: inline; margin-right: 1em; }
	          .setting input { width: 3em; }
	          label { font-weight: bold; }
	          .submit { margin-top: 1em; font-size: 200%; }
          </xsl:text>
        </style>
      </head>


      <body>
      	<div id="head">
	      <xsl:if test="$dbInfo/mp:logoURL">
	       <img class="logo" alt="Logo" src="{$dbInfo/mp:logoURL}"/>
	      </xsl:if>
	      
	      <h1>
	        <xsl:value-of select="$dbInfo/e:title"/>
	        <xsl:text> SRU interface</xsl:text>
	      </h1>
	      <p>
	        <xsl:value-of select="$dbInfo/e:description"/>
	        <xsl:if test="$dbInfo/mp:infoURL and $dbInfo/mp:infoString">
	        	<xsl:text> [</xsl:text>
	            <a href="{$dbInfo/mp:infoURL}">
	            		<xsl:value-of select="$dbInfo/mp:infoString"/>
	            </a>
	          <xsl:text>]</xsl:text>
	        </xsl:if>
	      </p>
      	</div>
      	
        <xsl:apply-templates select="/srw:explainResponse/diag:diagnostics"/>

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
                <xsl:value-of select="count(srw:record/srw:recordData/e:explain/e:indexInfo/e:index)"/>
              </xsl:attribute>
            </input>
            <xsl:for-each select="srw:record/srw:recordData/e:explain/e:indexInfo/e:index">
              <xsl:sort select="."/>
              <xsl:apply-templates select="."/>
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
          
          <div class="setting">
          	<label for="setting-schema">Schema:</label>
          	<select id="setting-schema" name="recordSchema" >
              <xsl:for-each select="srw:record/srw:recordData/e:explain/e:schemaInfo/e:schema">
                <option>
                  <xsl:attribute name="value">
                    <xsl:value-of select="@name"/>
                  </xsl:attribute>
                  <xsl:value-of select="e:title"/>
                </option>
              </xsl:for-each>
            </select>
          </div>
          
          <div class="setting">
          	<label for="setting-first">First Record:</label>
          	<input id="setting-first" name="startRecord" type="text" value="1"/>
          </div>

          <div class="setting">
          	<label for="setting-number">Number of Records:</label>
            <input id="setting-number" name="maximumRecords" type="text">
              <xsl:attribute name="value">
                <xsl:choose>
                  <xsl:when test="srw:record/srw:recordData/e:explain/e:configInfo/e:default[@type=&quot;numberOfRecords&quot;]">
                    <xsl:value-of select="srw:record/srw:recordData/e:explain/e:configInfo/e:default[@type=&quot;numberOfRecords&quot;]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>20</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </input>
          </div>
          
          <div>
              <input class="submit" type="submit" value="Search"/>
          </div>
        </form>
        
      </body>
    </html>
  </xsl:template>
  
  
  <xsl:template match="e:index">
	<tr>
	<td class="indexInfo">
	  <span class="indexName">
	    <xsl:value-of select="e:title"/>
	  </span>
	  <span class="indexID"><xsl:value-of select="e:map[1]/e:name/@set"/>.<xsl:value-of select="e:map[1]/e:name"/></span>
	  <input type="hidden">
	    <xsl:attribute name="name">index<xsl:number/></xsl:attribute>
	    <xsl:attribute name="value"><xsl:value-of select="e:map[1]/e:name/@set"/>.<xsl:value-of select="e:map[1]/e:name"/></xsl:attribute>
	  </input>
	</td>
	<td class="relation">
	  <select>
	    <xsl:attribute name="name">relat<xsl:number/></xsl:attribute>
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
	<td class="input">
	  <input type="text" value="">
	    <xsl:attribute name="name">term<xsl:number/></xsl:attribute>
	  </input>
	</td>
	<td class="boolean">
	  <select>
	    <xsl:attribute name="name">bool<xsl:number/></xsl:attribute>
	    <option value="and">and</option>
	    <option value="or">or</option>
	    <option value="not">not</option>
	  </select>
	</td>
	</tr>
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
