<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:mods="http://www.loc.gov/mods/v3"    
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="1.0">
    <!-- 
    ========================================================================================================================================================
                                                          METS/MODS -> MARCXML/Marc21 Conversion
                                                          
    this stylesheets assumes the METS/MODS format employed follows the following application profiles:
       - zvdd/DFG-Viewer METS-Profil Version 2.0 (http://www.zvdd.de/fileadmin/AGSDD-Redaktion/METS_Anwendungsprofil_2.0.pdf)
       - MODS Anwendungsprofil für digitalisierte Drucke Version 2.1 (http://www.zvdd.de/fileadmin/AGSDD-Redaktion/zvdd_MODS_Application_Profile_2.1.pdf)
       
    Last Change: 2013-06-05, Alex Jahnke, SUB Göttingen/Metadaten und Datenkonversion (jahnke@sub.uni-goettingen.de)
    ========================================================================================================================================================
    -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- ROOT Template -->
    <xsl:template match="/">
        <marc:collection>
            <xsl:apply-templates select="//mets:structMap[@TYPE='LOGICAL']/mets:div"/>
        </marc:collection>
    </xsl:template>
    
    <!-- 
        create Marc records from the first and, if necessary, the second level mets:div in the logical structMap element 
        Goobi generated METS will typically result in exactly one Marc record, while VisualLibrary output may create more than one record 
    -->
    <xsl:template match="mets:structMap[@TYPE='LOGICAL']/mets:div">
        <xsl:if test="@DMDID">
            <xsl:variable name="dmdid" select="@DMDID"/>
            <xsl:apply-templates select="//mets:dmdSec[@ID=$dmdid]/mets:mdWrap/mets:xmlData/mods:mods"/>
        </xsl:if>
        <xsl:if test="@TYPE='multivolume_work' or @TYPE='MultivolumeWork' or @TYPE='MultiVolumeWork' or @TYPE='Periodical' or @TYPE='periodical' or not(@DMDID)">
            <xsl:for-each select="child::mets:div">
                <xsl:variable name="dmdid" select="@DMDID"/>
                <xsl:apply-templates select="//mets:dmdSec[@ID=$dmdid]/mets:mdWrap/mets:xmlData/mods:mods"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!-- 
    ====================================================================================================================================================
                                                                      Marc record
    ====================================================================================================================================================
    -->
    <xsl:template match="mods:mods">
        <xsl:variable name="dmdid" select="ancestor::mets:dmdSec/@ID"/>
        <marc:record>
            <!-- record leader (ISO 2709) -->
            <marc:leader>           
                <xsl:text>00000cm</xsl:text>
                <xsl:choose>
                    <xsl:when test="//mets:structMap[@TYPE='LOGICAL']/mets:div[@DMDID=$dmdid]/@TYPE='Periodical' or //mets:structMap[@TYPE='LOGICAL']/mets:div[@DMDID=$dmdid]/@TYPE='periodical'">
                        <xsl:text>s</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>m</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> a2200000ui</xsl:text>
                <xsl:choose>
                    <xsl:when test="//mets:structMap[@TYPE='LOGICAL']/mets:div[@DMDID=$dmdid]/@TYPE='MultivolumeWork' or //mets:structMap[@TYPE='LOGICAL']/mets:div[@DMDID=$dmdid]/@TYPE='MultiVolumeWork' or //mets:structMap[@TYPE='LOGICAL']/mets:div[@DMDID=$dmdid]/@TYPE='multivolume_work'">
                        <xsl:text>a</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>4500</xsl:text>
            </marc:leader>
            <!-- record identifier and source (001, 003) -->
            <marc:controlfield tag="001">
                <xsl:value-of select="normalize-space(./mods:recordInfo/mods:recordIdentifier)"/>
            </marc:controlfield>
            <xsl:if test="./mods:recordInfo/mods:recordIdentifier/attribute::source">
                <marc:controlfield tag="003">
                    <xsl:value-of select="normalize-space(./mods:recordInfo/mods:recordIdentifier/attribute::source)"/>
                </marc:controlfield>  
            </xsl:if>
            <!-- no data element in zvdd METS/MODS to fill M21 field 005 -->
            <!-- Physical Description Fixed Field-General Information (007)  -->
            <marc:controlfield tag="007">
                <xsl:text>cr || |||||</xsl:text>
                <xsl:choose>
                    <xsl:when test="normalize-space(./mods:physicalDescription/mods:digitalOrigin)='reformatted digital'">
                        <xsl:text>a</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space(./mods:physicalDescription/mods:digitalOrigin)='digitized microfilm'">
                        <xsl:text>b</xsl:text>
                    </xsl:when> 
                    <xsl:when test="normalize-space(./mods:physicalDescription/mods:digitalOrigin)='digitized other analog'">
                        <xsl:text>d</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space(./mods:physicalDescription/mods:digitalOrigin)='born digital'">
                        <xsl:text>n</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>u</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>||</xsl:text>
            </marc:controlfield>
            <!-- Fixed-Length Data Elements-General Information (008) -->
            <marc:controlfield tag="008">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(./mods:recordInfo/mods:recordCreationDate[@encoding='marc']))=6">
                        <xsl:value-of select="normalize-space(./mods:recordInfo/mods:recordCreationDate[@encoding='marc'])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>700101</xsl:text> <!-- no data element in zvdd METS/MODS AP to fill M21 field 008/0-5, fill characters are not allowed, therefore default to 1.1.1970 --> 
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="./mods:originInfo[not(child::mods:edition[contains(text(),'[Electronic ed.]')])]/mods:dateIssued[@point='end' or @point='start']">
                        <xsl:text>m</xsl:text>
                        <xsl:choose>
                            <xsl:when test="string-length(./mods:originInfo[not(child::mods:edition[contains(text(),'[Electronic ed.]')])]/mods:dateIssued[@point='start'])=4">
                                <xsl:value-of select="./mods:originInfo[not(child::mods:edition[contains(text(),'[Electronic ed.]')])]/mods:dateIssued[@point='start']"/>        
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>uuuu</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="string-length(./mods:originInfo[not(child::mods:edition[contains(text(),'[Electronic ed.]')])]/mods:dateIssued[@point='end'])">
                                <xsl:value-of select="./mods:originInfo[not(child::mods:edition[contains(text(),'[Electronic ed.]')])]/mods:dateIssued[@point='end']"/>        
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>uuuu</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>                      
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>s</xsl:text>
                        <xsl:choose>
                            <xsl:when test="string-length(./mods:originInfo[not(child::mods:edition[contains(text(),'[Electronic ed.]')])]/mods:dateIssued[@keyDate='yes'])=4">
                                <xsl:value-of select="./mods:originInfo[not(child::mods:edition[contains(text(),'[Electronic ed.]')])]/mods:dateIssued[@keyDate='yes']"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>uuuu</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>    </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>xx </xsl:text> <!-- 008/15-17 place of publication, default to undefined, fill characters are discouraged -->
                <xsl:text>|||||||||||||||||</xsl:text> <!-- 008/18-34 material specific section, no attempt to code -->
                <xsl:choose> <!-- 008/35-37 language, only export if correct codes are used, otherwise default to 'und' -->
                    <xsl:when test="./mods:language/mods:languageTerm[@type='code' and @authority='iso639-2b' and string-length(text())=3]">
                        <xsl:value-of select="./mods:language/mods:languageTerm[@type='code' and @authority='iso639-2b']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>und</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>||</xsl:text> <!-- 008/38-39 no attempt to code -->
            </marc:controlfield>
            <!-- 
                VisualLibrary generated METS may omit mods:titleInfo within the description of a volume being part of a multivolume work or series
                hence the title proper must be retrieved from the description of the multivolume work itself
            -->
            <xsl:if test="not(./mods:titleInfo)">
                <xsl:variable name="parentDmdid" select="//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]//parent::node()/@DMDID"/>
                <xsl:apply-templates select="//mets:dmdSec[@ID=$parentDmdid]//mods:mods/mods:titleInfo[not(@type)]">
                    <xsl:with-param name="volumeDesignation" select="./mods:part/mods:detail/mods:number"/>
                </xsl:apply-templates>
            </xsl:if>
            <xsl:apply-templates/>
        </marc:record>
    </xsl:template>

    <!-- 
        ========================================================================================================================
                                                                 2.1 mods:titleInfo
        ========================================================================================================================
     -->

    <!-- mods:titleInfo -->
    <xsl:template match="mods:mods/mods:titleInfo[not(@type)]">
        <xsl:param name="volumeDesignation"/>
        <marc:datafield tag="245" ind1="0" >
            <xsl:choose>
                <xsl:when test="./mods:nonSort">
                    <xsl:attribute name="ind2">
                        <xsl:value-of select="string-length(normalize-space(./mods:nonSort))"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="ind2">0</xsl:attribute>                   
                </xsl:otherwise>
            </xsl:choose>
            <marc:subfield code="a">
                <xsl:if test="./mods:nonSort">
                    <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(./mods:title)"/>
                <xsl:choose>
                    <xsl:when test="./mods:subTitle">
                        <xsl:text> :</xsl:text>
                    </xsl:when>
                    <xsl:when test="../mods:note[@type='statementOfResponsibility']">
                        <xsl:text> /</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </marc:subfield>
            <xsl:apply-templates/>
            <xsl:if test="../mods:note[@type='statementOfResponsibility']">
                <marc:subfield code="c">
                    <xsl:value-of select="normalize-space(../mods:note[@type='statementOfResponsibility'])"/>
                </marc:subfield>               
            </xsl:if>
            <!-- SPECIAL CASE: periodical volumes -->
            <xsl:variable name="dmdid" select="ancestor::mets:dmdSec/@ID"/>
            <xsl:if test="contains('Periodical periodical',//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/@TYPE)">
                <marc:subfield code="n">
                    <xsl:value-of select="../mods:part/mods:detail/mods:number"/>
                </marc:subfield>
            </xsl:if>
            <!-- SPECIAL CASE: MVW volumes in VisualLibrary generated METS -->
            <xsl:if test="$volumeDesignation">
                <marc:subfield code="n">
                    <xsl:value-of select="$volumeDesignation"/>
                </marc:subfield>                
            </xsl:if>
        </marc:datafield>
    </xsl:template>

    <!-- mods:titleInfo (hostitem, field 490)-->
    <xsl:template match="mods:titleInfo[not(@type)]" mode="hostitem490">
        <marc:subfield code="a">
            <xsl:if test="./mods:nonSort">
                <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(./mods:title)"/>
            <xsl:if test="./mods:subTitle">
                <xsl:text> : </xsl:text>
                <xsl:value-of select="./mods:subTitle"/>
            </xsl:if>
            <xsl:if test="../mods:note[@type='statementOfResponsibility']">
                <xsl:text> / </xsl:text>
                <xsl:value-of select="normalize-space(../mods:note[@type='statementOfResponsibility'])"/>
            </xsl:if>
            <xsl:text> ;</xsl:text>
        </marc:subfield>
    </xsl:template>

    <!-- mods:titleInfo (hostitem, field 830)-->
    <xsl:template match="mods:titleInfo[not(@type)]" mode="hostitem830">
        <marc:subfield code="a">
            <xsl:if test="./mods:nonSort">
                <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(./mods:title)"/>
            <xsl:if test="./mods:subTitle">
                <xsl:text> : </xsl:text>
                <xsl:value-of select="./mods:subTitle"/>
            </xsl:if>
        </marc:subfield>
    </xsl:template>

    <!-- mods:titleInfo (hostitem, field 800)-->
    <xsl:template match="mods:titleInfo[not(@type)]" mode="hostitem800">
        <marc:subfield code="t">
            <xsl:if test="./mods:nonSort">
                <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(./mods:title)"/>
            <xsl:if test="./mods:subTitle">
                <xsl:text> : </xsl:text>
                <xsl:value-of select="./mods:subTitle"/>
            </xsl:if>
            <xsl:text>.</xsl:text>
        </marc:subfield>
    </xsl:template>

    <!-- mods:titleInfo[@type="abbreviated"] -->
    <xsl:template match="mods:mods/mods:titleInfo[@type='abbreviated']">
        <marc:datafield tag="210" ind1="0" ind2="0">
            <marc:subfield code="a">
                <xsl:if test="./mods:nonSort">
                    <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(./mods:title)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <!-- mods:titleInfo[@type="alternative" or @type='translated'] -->
    <xsl:template match="mods:mods/mods:titleInfo[@type='alternative' or @type='translated']">
        <marc:datafield tag="246" ind1="0" ind2=" ">
            <marc:subfield code="a">
                <xsl:if test="./mods:nonSort">
                    <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(./mods:title)"/>                
            <xsl:choose>
                <xsl:when test="./mods:subTitle">
                    <xsl:text> :</xsl:text>
                </xsl:when>
            </xsl:choose>
            </marc:subfield> 
            <xsl:apply-templates/>
        </marc:datafield>     
    </xsl:template>
    
    <!-- mods:titleInfo[@type='uniform'] -->
    <xsl:template match="mods:mods/mods:titleInfo[@type='uniform'][1]">
        <marc:datafield>
        <xsl:choose>
            <xsl:when test="../mods:name/mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut']">
                <xsl:attribute name="tag">240</xsl:attribute> 
                <xsl:attribute name="ind1">1</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="./mods:nonSort">
                        <xsl:attribute name="ind2">
                            <xsl:value-of select="string-length(normalize-space(./mods:nonSort))"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="ind2">0</xsl:attribute>                   
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="tag">130</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="./mods:nonSort">
                        <xsl:attribute name="ind1">
                            <xsl:value-of select="string-length(normalize-space(./mods:nonSort))"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="ind1">0</xsl:attribute>                   
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
            <marc:subfield code="a">
                <xsl:if test="./mods:nonSort">
                    <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(./mods:title)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:titleInfo[@type='uniform'][not(position()=1)]">
        <marc:datafield tag="730">
            <xsl:choose>
                <xsl:when test="./mods:nonSort">
                    <xsl:attribute name="ind1">
                        <xsl:value-of select="string-length(normalize-space(./mods:nonSort))"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="ind1">0</xsl:attribute>                   
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            <marc:subfield code="a">
                <xsl:if test="./mods:nonSort">
                    <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(./mods:title)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <!-- mods:titleInfo[not(@type) or @type="alternative"]/mods:subTitle --> 
    <xsl:template match="mods:subTitle">
        <marc:subfield code="b">
            <xsl:value-of select="normalize-space(.)"/>
            <!-- statement of resp. only in 245 (mods:titleInfo[not(@type)] -->
            <xsl:if test="../../mods:note[@type='statementOfResponsibility'] and not(../attribute::type)">
                <xsl:text> /</xsl:text>
            </xsl:if>            
        </marc:subfield>
    </xsl:template>

    <!--
        ==================================================================================================================================
                                                                    2.2 mods:name
        ==================================================================================================================================
    -->
    
    <!--mods:name[@type='personal'] -->
    <xsl:template match="mods:mods/mods:name[@type='personal']">
        <marc:datafield>
            <xsl:choose>
                <xsl:when test="./mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut'] and count(preceding::mods:name/mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut'])=0">
                    <xsl:attribute name="tag">100</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="tag">700</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="./mods:namePart[@type='family'] and ./mods:namePart[@type='given']">
                    <xsl:attribute name="ind1">1</xsl:attribute>
                </xsl:when>
                <xsl:when test="./mods:namePart[@type='family'] and not(./mods:namePart[@type='given'])">
                    <xsl:attribute name="ind1">3</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="ind1">0</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(./mods:namePart[@type='family'])"/>
                <xsl:if test="./mods:namePart[@type='family'] and ./mods:namePart[@type='given']">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:value-of select="normalize-space(./mods:namePart[@type='given'])"/>
                <xsl:if test="not(./mods:namePart[@type='family']) and not(./mods:namePart[@type='given'])">
                    <xsl:value-of select="./mods:namePart[1]"/>
                </xsl:if>
            </marc:subfield>
            <!-- Order of subfields in M21 requires separate apply-templates calls -->
            <xsl:apply-templates select="./mods:namePart"/>
            <xsl:apply-templates select="./mods:role/mods:roleTerm[@type='text']"/>
            <xsl:apply-templates select="./mods:role/mods:roleTerm[@type='code']"/>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:name[@type='personal']/mods:namePart[@type='termsOfAddress']">
        <marc:subfield code="c">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>

    <!-- mods:name[@type='personal'] (as main entry of hostitem, field 800)-->
    <xsl:template match="mods:mods/mods:name[@type='personal' and child::mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut']]" mode="hostitem800">
        <xsl:param name="volumeDesignation"/>
        <xsl:param name="hostitemId"/>
        <xsl:if test="count(preceding::mods:name/mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut'])=0">
            <marc:datafield tag="800">
                <xsl:choose>
                    <xsl:when test="./mods:namePart[@type='family'] and ./mods:namePart[@type='given']">
                        <xsl:attribute name="ind1">1</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="./mods:namePart[@type='family'] and not(./mods:namePart[@type='given'])">
                        <xsl:attribute name="ind1">3</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="ind1">0</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
                <marc:subfield code="a">
                    <xsl:value-of select="normalize-space(./mods:namePart[@type='family'])"/>
                    <xsl:if test="./mods:namePart[@type='family'] and ./mods:namePart[@type='given']">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(./mods:namePart[@type='given'])"/>
                    <xsl:if test="not(./mods:namePart[@type='family']) and not(./mods:namePart[@type='given'])">
                        <xsl:value-of select="./mods:namePart[1]"/>
                    </xsl:if>
                    <xsl:text>.</xsl:text>
                </marc:subfield>
                <xsl:apply-templates select="../mods:titleInfo" mode="hostitem800"/>
                <xsl:if test="$volumeDesignation">
                    <marc:subfield code="v">
                        <xsl:value-of select="$volumeDesignation"/>
                    </marc:subfield>
                </xsl:if>
                <marc:subfield code="w">
                    <xsl:if test="$hostitemId/@source">
                        <xsl:text>(</xsl:text>
                        <xsl:value-of select="$hostitemId/@source"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="normalize-space($hostitemId/text())"/>
                </marc:subfield>
            </marc:datafield>                
        </xsl:if>
    </xsl:template>

    <!--mods:name[@type='corporate'] -->
    <xsl:template match="mods:mods/mods:name[@type='corporate']">
        <marc:datafield>
            <xsl:choose>
                <xsl:when test="./mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut'] and count(preceding::mods:name/mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut'])=0">
                    <xsl:attribute name="tag">110</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="tag">710</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="ind1">2</xsl:attribute><!-- ind. 2 defaults to '2' -->
            <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            <!-- Order of subfields in M21 requires separate apply-templates calls -->
            <xsl:apply-templates select="./mods:namePart[not(@type)]"/>
            <xsl:apply-templates select="./mods:namePart[@type='date']"/> <!-- strictly speaking, in MODS this attribute value is not allowed within mods:name[@type='corporate'] -->
            <xsl:apply-templates select="./mods:role/mods:roleTerm[@type='text']"/>
            <xsl:apply-templates select="./mods:role/mods:roleTerm[@type='code']"/>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:name[@type='corporate']/mods:namePart[not(@type)]">
        <marc:subfield>
            <xsl:choose>
                <xsl:when test="position()=1">
                    <xsl:attribute name="code">a</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="code">b</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>
 
    <!-- all other sub elements of mods:name -->
    <xsl:template match="mods:namePart[@type='date']">
        <marc:subfield code="d">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>

    <xsl:template match="mods:role/mods:roleTerm[@type='code' and @authority='marcrelator']">
        <marc:subfield code="4">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>

    <xsl:template match="mods:role/mods:roleTerm[@type='text']">
        <marc:subfield code="e">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>

    <!-- 
    ============================================================================================================================
                                                             2.3 mods:genre
    ============================================================================================================================
    -->
    
    <xsl:template match="mods:mods/mods:genre">
        <marc:datafield tag="655" ind1=" ">
            <xsl:choose>
                <xsl:when test="@authority='marcgt'">
                    <xsl:attribute name="ind2">7</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="ind2">4</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
            <xsl:if test="@authority='marcgt'">
                <marc:subfield code="2">
                    <xsl:value-of select="@authority"/>
                </marc:subfield>
            </xsl:if>
        </marc:datafield>
    </xsl:template>

    <!-- 
    =============================================================================================================================
                                                              2.4 mods:originInfo
    =============================================================================================================================
    -->
    
    <!-- mods:originInfo, descr. the original publication -->
    <xsl:template match="mods:mods/mods:originInfo[not(mods:edition[text()='[Electronic ed.]'])]">
        <marc:datafield tag="260" ind1=" " ind2=" ">
            <xsl:choose>
                <xsl:when test="./mods:place/mods:placeTerm[@type='text']">
                    <xsl:apply-templates select="./mods:place"/>
                </xsl:when>
                <xsl:otherwise>
                    <marc:subfield code="a">
                        <xsl:text>[S.l.] :</xsl:text>
                    </marc:subfield>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="./mods:publisher">
                    <xsl:apply-templates select="./mods:publisher"/>
                </xsl:when>
                <xsl:otherwise>
                    <marc:subfield code="b">
                        <xsl:text>[s.n.],</xsl:text>
                    </marc:subfield>
                </xsl:otherwise>
            </xsl:choose>
            <marc:subfield code="c">
                <xsl:choose>
                    <xsl:when test="./mods:dateIssued">
                        <xsl:apply-templates select="./mods:dateIssued"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>[s.a.]</xsl:text>
                    </xsl:otherwise>
            </xsl:choose>
            </marc:subfield>
        </marc:datafield>
        <xsl:if test="./mods:edition">
            <marc:datafield tag="250" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:value-of select="normalize-space(substring-before(./mods:edition,' / '))"/>
                    <xsl:if test="contains(./mods:edition,' / ')">
                        <xsl:text> /</xsl:text>
                    </xsl:if>
                </marc:subfield>
                <xsl:if test="contains(./mods:edition,' / ')">
                    <marc:subfield code="b">
                        <xsl:value-of select="normalize-space(substring-after(./mods:edition,' / '))"/>
                    </marc:subfield>
                </xsl:if>
            </marc:datafield>
        </xsl:if>        
    </xsl:template>
    
    <xsl:template match="mods:originInfo[not(mods:edition[text()='[Electronic ed.]'])]/mods:place">
        <xsl:if test="./mods:placeTerm[@type='text']">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(./mods:placeTerm[@type='text'])"/>
                <xsl:choose>
                    <xsl:when test="following-sibling::mods:place[mods:placeTerm[@type='text']]">
                        <xsl:text> ;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> :</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </marc:subfield>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mods:originInfo[not(mods:edition[text()='[Electronic ed.]'])]/mods:publisher">
        <marc:subfield code="b">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:choose>
                <xsl:when test="following-sibling::mods:publisher">
                    <xsl:text> :</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>,</xsl:text>
                </xsl:otherwise>
            </xsl:choose>            
        </marc:subfield>
    </xsl:template>
    
    <xsl:template match="mods:originInfo[not(mods:edition[text()='[Electronic ed.]'])]/mods:dateIssued">
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:if test="@point='start'">
            <xsl:text>-</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- mods:originInfo, descr. the original publication (hostitem, field 773) -->
    <!--
    <xsl:template match="mods:mods/mods:originInfo[not(mods:edition[text()='[Electronic ed.]'])]" mode="hostitem">
        <xsl:if test="./mods:edition">
            <marc:subfield code="b">
                <xsl:value-of select="normalize-space(./mods:edition)"/>
            </marc:subfield>
        </xsl:if>           
        <marc:subfield code="d">
            <xsl:choose>
                <xsl:when test="./mods:place/mods:placeTerm[@type='text']">
                    <xsl:value-of select="normalize-space(./mods:place/mods:placeTerm[@type='text'][1])"/>
                    <xsl:if test="count(./mods:place/mods:placeTerm[@type='text'])>1">
                        <xsl:text> [u.a.]</xsl:text>
                    </xsl:if>
                    <xsl:text> : </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>[S.l.] : </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="./mods:publisher">
                    <xsl:value-of select="normalize-space(./mods:publisher[1])"/>
                    <xsl:if test="count(./mods:publisher[@type='text'])>1">
                        <xsl:text> [u.a.]</xsl:text>
                    </xsl:if>
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>[s.n.], </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="./mods:dateIssued">
                    <xsl:value-of select="normalize-space(./mods:dateIssued[@keyDate])"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>[s.a.]</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </marc:subfield>     
    </xsl:template>
   -->
   <!-- mods:originInfo, descr. the digital copy -->
    <xsl:template match="mods:mods/mods:originInfo[mods:edition[text()='[Electronic ed.]']]">
        <marc:datafield tag="533" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(./mods:edition)"/>
            </marc:subfield>
            <xsl:apply-templates select="./mods:place | ./mods:publisher"/>
            <xsl:if test="./mods:dateCaptured">
                <marc:subfield code="d">
                    <xsl:apply-templates select="./mods:dateCaptured"/>
                </marc:subfield>
            </xsl:if>
        </marc:datafield>
    </xsl:template> 
    
    <xsl:template match="mods:mods/mods:originInfo[mods:edition[text()='[Electronic ed.]']]/mods:place/mods:placeTerm[@type='text']">
        <marc:subfield code="b">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:originInfo[mods:edition[text()='[Electronic ed.]']]/mods:publisher">
        <marc:subfield code="c">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:originInfo[mods:edition[text()='[Electronic ed.]']]/mods:dateCaptured">
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:if test="@point='start'">
            <xsl:text>-</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- 
    ============================================================================================================================
                                              2.5 mods:language
    ============================================================================================================================
    -->
    
    <!-- mods:language, map to 041 only if more than one occ. -->
    <xsl:template match="mods:mods/mods:language[2]">
        <xsl:if test="count(../mods:language[child::mods:languageTerm[@type='code' and @authority='iso639-2b' and string-length(text())=3]])>1">
            <marc:datafield tag="041" ind1=" " ind2=" ">
                <xsl:for-each select="../mods:language[child::mods:languageTerm[@type='code' and @authority='iso639-2b' and string-length(text())=3]]">
                   <marc:subfield code="a">
                       <xsl:value-of select="./mods:languageTerm[@type='code' and @authority='iso639-2b' and string-length(text())=3]"/>
                   </marc:subfield>
               </xsl:for-each> 
            </marc:datafield>
        </xsl:if>
    </xsl:template>

    <!-- 
    ============================================================================================================================
                                              2.6 mods:physicalDescription/mods:extent
    ============================================================================================================================
    -->
    
    <xsl:template match="mods:mods/mods:physicalDescription[child::mods:extent]">
        <marc:datafield tag="300" ind1=" " ind2=" ">
            <xsl:apply-templates select="./mods:extent"/>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:physicalDescription/mods:extent">
        <xsl:choose>
            <xsl:when test="count(preceding-sibling::mods:extent)=0">
                <marc:subfield>
                    <xsl:attribute name="code">a</xsl:attribute>
                    <xsl:value-of select="normalize-space(.)"/>
                </marc:subfield>
            </xsl:when>
            <xsl:when test="count(preceding-sibling::mods:extent)=1">
                <marc:subfield>
                    <xsl:attribute name="code">b</xsl:attribute>
                    <xsl:for-each select=". | following-sibling::mods:extent">
                        <xsl:choose>
                            <xsl:when test="position()=1">
                                <xsl:value-of select="concat(': ',.)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(', ',.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </marc:subfield>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- 
    ============================================================================================================================
                                                           2.7 mods:abstract
    ============================================================================================================================
    -->
    
    <xsl:template match="mods:mods/mods:abstract">
        <marc:datafield tag="520" ind1="3" ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <!-- 
    =============================================================================================================================
                                                             2.8 mods:note
    =============================================================================================================================
    -->
    
    <xsl:template match="mods:mods/mods:note" priority="0.25">
        <marc:datafield tag="500" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:note[@type='statementOfResponsibility']"/>


    <xsl:template match="mods:mods/mods:note[@type='acquisition']">
        <marc:datafield tag="541" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='action']">
        <marc:datafield tag="583" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:note[@type='additional physical form']">
        <marc:datafield tag="530" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='bibliography']">
        <marc:datafield tag="504" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='bibliographical/historical']">
        <marc:datafield tag="545" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:note[@type='citation/reference']">
        <marc:datafield tag="510" ind1="0" ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template> 
    
    <xsl:template match="mods:mods/mods:note[@type='creation/production credits']">
        <marc:datafield tag="508" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:note[@type='date']">
        <marc:datafield tag="518" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='exhibitions']">
        <marc:datafield tag="585" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='funding']">
        <marc:datafield tag="536" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='handwritten']">
        <marc:datafield tag="562" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='language']">
        <marc:datafield tag="546" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='numbering']">
        <marc:datafield tag="515" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='date/sequential designation']">
        <marc:datafield tag="362" ind1="1" ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='original location']">
        <marc:datafield tag="535" ind1="1" ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='ownership']">
        <marc:datafield tag="561" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='performers']">
        <marc:datafield tag="511" ind1="0" ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='preferred citation']">
        <marc:datafield tag="524" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:note[@type='publications']">
        <marc:datafield tag="581" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:note[@type='restriction']">
        <marc:datafield tag="506" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:note[@type='system details']">
        <marc:datafield tag="538" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:note[@type='venue']">
        <marc:datafield tag="518" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:note[@type='version identification']">
        <marc:datafield tag="562" ind1=" " ind2=" ">
            <marc:subfield code="c">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:note[@type='thesis']">
        <marc:datafield tag="502" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <!-- 
    =========================================================================================================================
                                                            2.9 mods:subject
    =========================================================================================================================
    -->
    
    <xsl:template match="mods:mods/mods:subject">
        <marc:datafield>
            <xsl:choose>
                <xsl:when test="child::node()[1]=mods:topic">
                    <xsl:attribute name="tag">650</xsl:attribute>    
                </xsl:when>
                <xsl:when test="child::node()[1]=mods:geographic">
                    <xsl:attribute name="tag">651</xsl:attribute>    
                </xsl:when>                
                <xsl:when test="child::node()[1]=mods:temporal">
                    <xsl:attribute name="tag">650</xsl:attribute>    
                </xsl:when>
                <xsl:when test="child::node()[1]=mods:titleInfo">
                    <xsl:attribute name="tag">630</xsl:attribute>    
                </xsl:when>
                <xsl:when test="child::node()[1]=mods:name[@type='personal']">
                    <xsl:attribute name="tag">600</xsl:attribute>    
                </xsl:when>
                <xsl:when test="child::node()[1]=mods:name[@type='corporate']">
                    <xsl:attribute name="tag">600</xsl:attribute>    
                </xsl:when>  
                <xsl:when test="child::node()[1]=mods:hierarchicalGeographic">
                    <xsl:attribute name="tag">662</xsl:attribute>    
                </xsl:when>                  
                <xsl:otherwise>
                    <xsl:attribute name="tag">690</xsl:attribute>    
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            <xsl:choose>
                <xsl:when test="child::node()[1]=mods:hierarchicalGeographic">
                    <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
                </xsl:when>
                <xsl:when test="@authority">
                    <xsl:attribute name="ind2">7</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="ind2">4</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <marc:subfield code="a">
                <xsl:choose>
                    <xsl:when test="child::node()[1]=mods:titleInfo">
                        <xsl:if test="./mods:nonSort">
                            <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(./mods:title)"/>      
                    </xsl:when>
                    <xsl:when test="child::node()[1]=mods:name[@type='personal']">
                        <xsl:value-of select="normalize-space(./mods:name/mods:namePart[@type='family'])"/>
                        <xsl:if test="./mods:name/mods:namePart[@type='family'] and ./mods:name/mods:namePart[@type='given']">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(./mods:name/mods:namePart[@type='given'])"/>    
                    </xsl:when>
                    <xsl:when test="child::node()[1]=mods:name[@type='corporate']">
                        <xsl:value-of select="normalize-space(./mods:name/mods:namePart[not(@type)])"/>    
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(child::node()[1])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </marc:subfield>
            <xsl:apply-templates select="child::node()[position()>1]"/>
            <xsl:if test="@authority">
                <marc:subfield code="2">
                    <xsl:choose>
                        <xsl:when test="contains('aass aat abne agrifors agrovoc agrovocf agrovocs afset aiatsisl aiatsisp aiatsiss aktp albt allars apaist asft asrcrfcd asrctoa asth atg atla aucsh barn bella bet bhammf bhashe bib1814 bibalex biccbmc bicssc bidex bisacmt bisacrt bisacsh bjornson blcpss blmlsh blnpn bt cabt cash ccsa cct ccte cctf cdcng ceeus chirosh cht ciesiniv cilla collett conorsi csahssa csalsct csapa csh csht cstud czenas dcs ddcri ddcrit ddcut dissao dit drama dtict ebfem eclas eet eflch eks embne emnmus ept erfemn ericd est eum eurovocen fast finmesh fire fmesh francis galestne gccst gem geonet georeft gnd gnis gst gtt hamsun hapi helecon henn hkcan hlasstg hoidokki hrvmesh huc humord ica icpsr idas idsbb idszbz idszbzes idszbzna idszbzzg idszbzzh idszbzzk iescs iest ilpt inist inspect ipsp isis itglit itrt jhpb jhpk jlabsh jurivoc kaa kao kaunokki kdm kitu kkts kssbar kta ktpt ktta kula kupu lacnaf larpcal lcac lcdgt lcmpt lcsh lcshac lcstt lctgm lemac lemb liv lnmmbr local ltcsh lua maaq mar masa mech mesh mipfesd mmm mpirdes msc msh mtirdes musa muzeukc muzeukn muzvukci naf nal nalnaf nasat nbiemnfag ncjt ndlsh netc nicem nimacsc nlgaf nlgkk nlgsh nlmnaf no-ubo-mr noraf noubojur noram norbok noubomn nsbncf nskps ntcpsc ntcsd ntids ntissc nzggn nznb ogst opms ordnok pascal peri pha pmbok pmcsg pmont pmt poliscit popinte pkk precis prvt psychit qlsp qrma qrmak qtglit quiding ram rasuqam renib reo rero rerovoc rma rpe rswk rswkaf rugeo rurkp rvm samisk sanb sao sbiao sbt scbi scgdst scisshl scot sears sfit sgc sgce shbe she shsples sigle sipri sk skon slem smda snt socio solstad sosa spines ssg stw swd swemesh taika taxhs tekord tesa test tgn thesoz tho thub tlka tlsh trt trtsa tsht ttka tucua ukslc ulan umitrist unbisn unbist unescot usaidt vmj waqaf watrest wgst wot wpicsh ysa',@authority)">
                            <xsl:value-of select="@authority"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>local</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </marc:subfield>
            </xsl:if>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:subject/mods:topic">
        <marc:subfield code="x">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>
 
    <xsl:template match="mods:subject/mods:geographic">
        <marc:subfield code="y">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>
    
    <xsl:template match="mods:subject/mods:temporal">
        <marc:subfield code="z">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>
    
    <xsl:template match="mods:subject/mods:titleInfo">
        <marc:subfield code="t">
            <xsl:if test="./mods:nonSort">
                <xsl:value-of select="concat(normalize-space(./mods:nonSort),' ')"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(./mods:title)"/>   
        </marc:subfield>
    </xsl:template>
    
    <xsl:template match="mods:subject/mods:name[@type='personal']">
        <marc:subfield code="x">
            <xsl:value-of select="normalize-space(./mods:namePart[@type='family'])"/>
            <xsl:if test="./mods:namePart[@type='family'] and ./mods:namePart[@type='given']">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="normalize-space(./mods:namePart[@type='given'])"/>
            <xsl:if test="not(./mods:namePart[@type='family']) and not(./mods:namePart[@type='given'])">
                <xsl:value-of select="./mods:namePart[1]"/>
            </xsl:if>            
        </marc:subfield>
    </xsl:template>

    <xsl:template match="mods:subject/mods:name[@type='corporate']">
        <marc:subfield code="x">
            <xsl:value-of select="normalize-space(./mods:namePart[not(@type)])"/>          
        </marc:subfield>
    </xsl:template>
    
    <xsl:template match="mods:subject/mods:hierarchicalGeographic">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="mods:continent|mods:country">
        <marc:subfield code="a">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>

    <xsl:template match="mods:province|mods:region|mods:state|mods:territory|mods:county">
        <marc:subfield code="c">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>

    <xsl:template match="mods:city">
        <marc:subfield code="d">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>
    
    <xsl:template match="mods:citySection">
        <marc:subfield code="f">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>
    
    <xsl:template match="mods:island|mods:area">
        <marc:subfield code="g">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>
    
    <xsl:template match="mods:extraterrestialArea">
        <marc:subfield code="h">
            <xsl:value-of select="normalize-space(.)"/>
        </marc:subfield>
    </xsl:template>
    

    <!-- 
    ==========================================================================================================================
                                                        2.10 mods:classification
    ==========================================================================================================================
    -->
    
    <!-- mods:classification (fallback) -->
    <xsl:template match="mods:mods/mods:classification" priority="0.25">
        <marc:datafield tag="084" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
            <xsl:if test="@authority">
                <marc:subfield code="2">
                    <xsl:choose>
                        <xsl:when test="contains('accs acmccs agricola agrissc anscr ardocs asb azdocs bar bcl bcmc bisacsh bkl bliss blissc blsrissc cacodoc cadocs ccpgq celex chfbn clc clutscny codocs cslj cstud cutterec ddc dopaed egedeklass ekl farl farma fcps fiaf finagri flarch fldocs frtav gadocs gfdc ghbs iadocs ics ifzs inspec ipc jelc kab kfmod kktb knt ksdocs kssb kuvacs laclaw ladocs lcc loovs methepp midocs misklass mmlcc mf-klass modocs moys mpkkl msc msdocs mu naics nasasscg nbdocs ncdocs ncsclt nhcp nicem niv njb nlm nmdocs no-ujur-cmr no-ujur-cnip no-ureal-ca no-ureal-cb no-ureal-cg noterlyd nvdocs nwbib nydocs ohdocs okdocs oosk ordocs padocs pssppbkj rich ridocs rilm rpb rswk rubbk rubbkd rubbkk rubbkm rubbkmv rubbkn rubbknp rubbko rubbks rueskl rugasnti rvk sbb scdocs sddocs sdnb sfb siblcs skb smm ssd ssgn sswd stub suaslc sudocs swank taikclas taykl teatkl txdocs tykoma ubtkl/2 udc uef undocs upsylon usgslcs utk utklklass utklklassex utdocs veera vsiso wadocs widocs wydocs ykl z zdbs',@authority)">
                            <xsl:value-of select="@authority"/> 
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>z</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>                   
                </marc:subfield>
            </xsl:if>
        </marc:datafield>
    </xsl:template>
    
    <!-- mods:classification[@autority="ddc"] -->
    <xsl:template match="mods:mods/mods:classification[@authority='ddc' or @authorityURI='http://dewey.info']">
        <marc:datafield tag="082" ind1="0" ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
            <xsl:if test="@edition">
                <marc:subfield code="2">
                    <xsl:value-of select="@edition"/>
                </marc:subfield>
            </xsl:if>
        </marc:datafield>
    </xsl:template>
    
    <!-- mods:classification[@autority="udc"] -->
    <xsl:template match="mods:mods/mods:classification[@authority='udc']">
        <marc:datafield tag="080" ind1=" " ind2=" ">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
            <xsl:if test="@edition">
                <marc:subfield code="2">
                    <xsl:value-of select="@edition"/>
                </marc:subfield>
            </xsl:if>
        </marc:datafield>
    </xsl:template>  

    <!-- mods:classification[@autority="lcc"] -->
    <xsl:template match="mods:mods/mods:classification[@authority='lcc']">
        <marc:datafield tag="050" ind1=" " ind2="4">
            <marc:subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <!-- mods:classification[@authority="ZVDD"] -->
    <xsl:template match="mods:mods/mods:classification[@authority='ZVDD']"/>

    <!-- mods:classification[@authority="GDZ"] -->
    <xsl:template match="mods:mods/mods:classification[@authority='GDZ']"/>
    
    <!-- 
    ==========================================================================================================================
                                                            2.11 mods:relatedItem
    ==========================================================================================================================
    -->
    
    <!-- mods:relatedItem[@type='series'] -->
    <xsl:template match="mods:mods/mods:relatedItem[@type='series']">
        <xsl:choose>
            <xsl:when test="./mods:titleInfo">
                <marc:datafield tag="490" ind1="0" ind2=" ">
                  <marc:subfield code="a">
                      <xsl:if test="./mods:titleInfo/mods:nonSort">
                          <xsl:value-of select="concat(normalize-space(./mods:titleInfo/mods:nonSort),' ')"/>
                      </xsl:if>
                      <xsl:value-of select="normalize-space(./mods:titleInfo/mods:title)"/>                     
                  </marc:subfield> 
                  <xsl:if test="./mods:part/mods:detail[@type='volume' or @type='issue']/mods:number">
                      <marc:subfield code="v">
                          <xsl:value-of select="normalize-space(./mods:part/mods:detail[@type='volume']/mods:number)"/>
                          <xsl:if test="./mods:part/mods:detail[@type='volume']/mods:number and ./mods:part/mods:detail[@type='issue']/mods:number">
                              <xsl:text>,</xsl:text>
                          </xsl:if>
                          <xsl:value-of select="normalize-space(./mods:part/mods:detail[@type='issue']/mods:number)"/>
                      </marc:subfield>
                  </xsl:if>
                </marc:datafield>               
            </xsl:when>
            <!-- TODO: AP allows also for reference by Identifier only in mods:relatedItem[@type='series'] --> 
        </xsl:choose>
    </xsl:template>

    <!-- mods:relatedItem[@type='series'] (hostitem, field 773) -->
    <!--
    <xsl:template match="mods:mods/mods:relatedItem[@type='series']" mode="hostitem">
        <xsl:if test="./mods:titleInfo">
            <marc:subfield code="k">
                <xsl:if test="./mods:titleInfo/mods:nonSort">
                    <xsl:value-of select="concat(normalize-space(./mods:titleInfo/mods:nonSort),' ')"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(./mods:titleInfo/mods:title)"/>                     
                <xsl:if test="./mods:part/mods:detail[@type='volume' or @type='issue']/mods:number">
                    <xsl:text> ; </xsl:text>
                    <xsl:value-of select="normalize-space(./mods:part/mods:detail[@type='volume']/mods:number)"/>
                    <xsl:if test="./mods:part/mods:detail[@type='volume']/mods:number and ./mods:part/mods:detail[@type='issue']/mods:number">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(./mods:part/mods:detail[@type='issue']/mods:number)"/>
                </xsl:if>
            </marc:subfield>            
        </xsl:if>
    </xsl:template>
    -->

    <!-- mods:relatedItem[@type='host'] -->
    <xsl:template match="mods:mods/mods:relatedItem[@type='host']">
        <xsl:variable name="dmdid" select="ancestor::mets:dmdSec/@ID"/>
        <!-- none of the following applies to periodical volumes -->
        <xsl:if test="not(contains('Periodical periodical',//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/@TYPE))">
            <!-- 
                if a volume has a title proper, it is given in 245, while the title of the multivolume work is given in 490 and 830 
            -->
            <xsl:if test="../mods:titleInfo[not(@type)]">
                <xsl:variable name="parentDmdId" select="//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/@DMDID"/>
                <xsl:choose>
                    <xsl:when test="document(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/mets:mptr/@xlink:href)/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo">
                        <marc:datafield tag="490" ind1="1" ind2=" ">
                            <xsl:apply-templates select="document(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/mets:mptr/@xlink:href)/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo" mode="hostitem490"/>
                            <marc:subfield code="v">
                                <xsl:value-of select="normalize-space(../mods:part/mods:detail/mods:number)"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="//mets:dmdSec[@ID=$parentDmdId]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo">
                        <marc:datafield tag="490" ind1="1" ind2=" ">
                            <xsl:apply-templates select="//mets:dmdSec[@ID=$parentDmdId]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo" mode="hostitem490"/>
                            <marc:subfield code="v">
                                <xsl:value-of select="normalize-space(../mods:part/mods:detail/mods:number)"/>
                            </marc:subfield>
                        </marc:datafield>                        
                    </xsl:when>
                </xsl:choose>
                
                <!-- 8XX for Goobi generated METS -->
                <xsl:choose>
                    <xsl:when test="document(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/mets:mptr/@xlink:href)/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:name[@type='personal']/mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut']">
                        <xsl:apply-templates select="document(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/mets:mptr/@xlink:href)/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:name[@type='personal' and child::mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut']]" mode="hostitem800">
                            <xsl:with-param name="volumeDesignation" select="normalize-space(../mods:part/mods:detail/mods:number)"/>
                            <xsl:with-param name="hostitemId" select="./mods:recordInfo/mods:recordIdentifier"></xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="document(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/mets:mptr/@xlink:href)/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo">
                      <marc:datafield tag="830" ind1="0" ind2=" ">
                          <xsl:apply-templates select="document(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/mets:mptr/@xlink:href)/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo" mode="hostitem830"/>
                          <marc:subfield code="v">
                              <xsl:value-of select="normalize-space(../mods:part/mods:detail/mods:number)"/>
                          </marc:subfield>
                          <marc:subfield code="w">
                              <xsl:if test="./mods:recordInfo/mods:recordIdentifier/@source">
                                  <xsl:text>(</xsl:text>
                                  <xsl:value-of select="./mods:recordInfo/mods:recordIdentifier/@source"/>
                                  <xsl:text>)</xsl:text>
                              </xsl:if>
                              <xsl:value-of select="normalize-space(./mods:recordInfo/mods:recordIdentifier)"/>
                          </marc:subfield>
                      </marc:datafield>
                    </xsl:when>
                    <xsl:when test="//mets:dmdSec[@ID=$parentDmdId]/mets:mdWrap/mets:xmlData/mods:mods/mods:name[@type='personal']/mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut']">
                        <xsl:apply-templates select="//mets:dmdSec[@ID=$parentDmdId]/mets:mdWrap/mets:xmlData/mods:mods/mods:name[@type='personal' and child::mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut']]" mode="hostitem800">
                            <xsl:with-param name="volumeDesignation" select="normalize-space(../mods:part/mods:detail/mods:number)"/>
                            <xsl:with-param name="hostitemId" select="./mods:recordInfo/mods:recordIdentifier"></xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:when>                        
                    <xsl:when test="not(//mets:dmdSec[@ID=$parentDmdId]/mets:mdWrap/mets:xmlData/mods:mods/mods:name[@type='personal']/mods:role/mods:roleTerm[@type='code' and @authority='marcrelator' and text()='aut'])">
                        <marc:datafield tag="830" ind1="0" ind2=" ">
                            <xsl:apply-templates select="//mets:dmdSec[@ID=$parentDmdId]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo[not(@type)]" mode="hostitem830"/>
                            <marc:subfield code="v">
                                <xsl:value-of select="normalize-space(../mods:part/mods:detail/mods:number)"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:if test="./mods:recordInfo/mods:recordIdentifier/@source">
                                    <xsl:text>(</xsl:text>
                                    <xsl:value-of select="./mods:recordInfo/mods:recordIdentifier/@source"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="normalize-space(./mods:recordInfo/mods:recordIdentifier)"/>
                            </marc:subfield>
                        </marc:datafield>                        
                    </xsl:when>
                </xsl:choose>
                
                
                <!--
                <xsl:apply-templates select="document(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/mets:mptr/@xlink:href)/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:name" mode="hostitem"/>
                <xsl:apply-templates select="document(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/mets:mptr/@xlink:href)/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:originInfo" mode="hostitem"/>
                <xsl:apply-templates select="document(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdid]/parent::node()/mets:mptr/@xlink:href)/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:relatedItem" mode="hostitem"/>
                -->
            </xsl:if>
            <!-- 
                if volume has no title proper, the title of the multivolume work incl. the volume designation is given in 245
                a link is made in 773
            -->
            <xsl:if test="not(../mods:titleInfo[not(@type)])">
                <marc:datafield tag="773" ind1="0" ind2="8">
                    <marc:subfield code="w">
                        <xsl:if test="./mods:recordInfo/mods:recordIdentifier/@source">
                            <xsl:text>(</xsl:text>
                            <xsl:value-of select="./mods:recordInfo/mods:recordIdentifier/@source"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(./mods:recordInfo/mods:recordIdentifier)"/>
                    </marc:subfield>
                    <marc:subfield code="g">
                        <xsl:value-of select="normalize-space(../mods:part/mods:detail/mods:number)"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- mods:relatedItem[@type='preceding'] process only if a title is given in mods:relatedItem -->
    <xsl:template match="mods:mods/mods:relatedItem[@type='preceding' and child::mods:titleInfo]">
        <xsl:variable name="dmdid" select="ancestor::mets:dmdSec/@ID"/>
            <marc:datafield tag="780" ind1="0" ind2="0">
                <xsl:apply-templates select="./mods:name" mode="hostitem"/>
                <xsl:apply-templates select="./mods:titleInfo" mode="hostitem"/>
                <xsl:apply-templates select="./mods:originInfo" mode="hostitem"/>
                <marc:subfield code="w">
                    <xsl:if test="./mods:recordInfo/mods:recordIdentifier/@source">
                        <xsl:text>(</xsl:text>
                        <xsl:value-of select="./mods:recordInfo/mods:recordIdentifier/@source"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(./mods:recordInfo/mods:recordIdentifier)"/>
                </marc:subfield>
            </marc:datafield>        
    </xsl:template>

    <!-- mods:relatedItem[@type='preceding'] process only if a title is given in mods:relatedItem -->
    <xsl:template match="mods:mods/mods:relatedItem[@type='suceeding' and child::mods:titleInfo]">
        <xsl:variable name="dmdid" select="ancestor::mets:dmdSec/@ID"/>
        <marc:datafield tag="785" ind1="0" ind2="0">
            <xsl:apply-templates select="./mods:name" mode="hostitem"/>
            <xsl:apply-templates select="./mods:titleInfo" mode="hostitem"/>
            <xsl:apply-templates select="./mods:originInfo" mode="hostitem"/>
            <marc:subfield code="w">
                <xsl:if test="./mods:recordInfo/mods:recordIdentifier/@source">
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="./mods:recordInfo/mods:recordIdentifier/@source"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
                <xsl:value-of select="normalize-space(./mods:recordInfo/mods:recordIdentifier)"/>
            </marc:subfield>
        </marc:datafield>        
    </xsl:template>

    <!-- 
    ===============================================================================================================================================================
                                                             2.12 mods:identifier
    ===============================================================================================================================================================
    -->
    
    <!-- mods:identifier default (024) -->
    <xsl:template match="mods:mods/mods:identifier" priority="0.25">
        <marc:datafield tag="024">
            <xsl:choose>
                <xsl:when test="not(@type)">
                    <xsl:attribute name="ind1">8</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='ismn'">
                    <xsl:attribute name="ind1">2</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='isrc'">
                    <xsl:attribute name="ind1">0</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='sici'">
                    <xsl:attribute name="ind1">4</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='upc'">
                    <xsl:attribute name="ind1">1</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="ind1">7</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            <xsl:choose>
                <xsl:when test="@invalid='yes'">
                    <marc:subfield code="z">
                        <xsl:value-of select="normalize-space(.)"/>
                    </marc:subfield>
                </xsl:when>
                <xsl:otherwise>
                    <marc:subfield code="a">
                        <xsl:value-of select="normalize-space(.)"/>
                    </marc:subfield>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@type and not(contains('ismn isrc sici upc',@type))">
                <marc:subfield code="2">
                    <xsl:choose>
                        <xsl:when test="not(contains('ansi danacode doi ean gtin-14 dl isan iso issue-number istc iswc itar matrix-number music-plate music-publisher natgazfid nipo orcid videorecording-identifier',@type))">
                            <xsl:text>local</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </marc:subfield>
            </xsl:if>
        </marc:datafield>
    </xsl:template>

    <!-- mods:identifier[@type='isbn'] (020) -->
    <xsl:template match="mods:mods/mods:identifier[@type='isbn']">
        <marc:datafield tag="020" ind1=" " ind2=" ">
            <marc:subfield>
                <xsl:choose>
                    <xsl:when test="@invalid='yes'">
                        <xsl:attribute name="code">z</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="code">a</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <!-- mods:identifier[@type='issn'] (022) -->
    <xsl:template match="mods:mods/mods:identifier[@type='issn']">
        <marc:datafield tag="022" ind1=" " ind2=" ">
            <marc:subfield>
                <xsl:choose>
                    <xsl:when test="@invalid='yes'">
                        <xsl:attribute name="code">z</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="code">a</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <xsl:template match="mods:mods/mods:identifier[@type='issn-l']">
        <marc:datafield tag="022" ind1=" " ind2=" ">
            <marc:subfield>
                <xsl:choose>
                    <xsl:when test="@invalid='yes'">
                        <xsl:attribute name="code">m</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="code">l</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <!-- mods:identifier[@type='lccn'] (010) -->
    <xsl:template match="mods:mods/mods:identifier[@type='lccn']">
        <marc:datafield tag="010" ind1=" " ind2=" ">
            <marc:subfield>
                <xsl:choose>
                    <xsl:when test="@invalid='yes'">
                        <xsl:attribute name="code">z</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="code">a</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <!-- mods:identifier[@type='strn'] (027) -->
    <xsl:template match="mods:mods/mods:identifier[@type='strn']">
        <marc:datafield tag="027" ind1=" " ind2=" ">
            <marc:subfield>
                <xsl:choose>
                    <xsl:when test="@invalid='yes'">
                        <xsl:attribute name="code">z</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="code">a</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <!-- mods:identifier[@type='uri'] (856) -->
    <xsl:template match="mods:mods/mods:identifier[@type='uri' or @type='urn']">
        <marc:datafield tag="856" ind1=" " ind2="0">
            <marc:subfield code="u">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>

    <!-- 
    ==============================================================================================================================================================
                                                                 2.13 mods:location
    ==============================================================================================================================================================
    -->
    
    <!-- mods:url -->
    <xsl:template match="mods:mods/mods:location/mods:url">
        <marc:datafield tag="856" ind1="4" ind2="0">
            <marc:subfield code="u">
                <xsl:value-of select="normalize-space(.)"/>
            </marc:subfield>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:location[child::mods:shelfLocator or child::mods:physicalLocation]">
        <marc:datafield tag="852" ind1=" " ind2=" ">
            <xsl:if test="./mods:physicalLocation">
                <marc:subfield code="a">
                    <xsl:value-of select="normalize-space(./mods:physicalLocation)"/>
                </marc:subfield>
            </xsl:if>
            <xsl:if test="./mods:shelfLocator">
                <marc:subfield code="j">
                    <xsl:value-of select="normalize-space(./mods:shelfLocator)"/>
                </marc:subfield>
            </xsl:if>            
        </marc:datafield>
    </xsl:template>

    <!-- 
    ==============================================================================================================================================================    
                                                                          Fallback  
    ==============================================================================================================================================================
    -->
    
    <xsl:template match="@*|text()"/>  
    <xsl:template match="@*|text()" mode="hostitem"/>
    
</xsl:stylesheet>