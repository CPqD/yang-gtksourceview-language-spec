<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:yang="http://cpqd.com.br/yang/gtksourceview-3.0-styles">
    
<!--
<statement name="type" style="keyword2">
    <argument type="multiple">
        <argument type="ref" context="types"/>
        <argument type="match" pattern="\%{identifier-with-ns}" style="special"/>
    </argument>
    <substatement name="type"/>
    <substatement name="type-properties"/>
</statement>

<context id="type">
    <start extended="true">\btype(?=\s+\%{identifier-with-ns})</start><end>;|}</end>
    <include>
        <context sub-pattern="0" where="start" style-ref="keyword2"/>
        <context id="type-argument">
            <start>\s+</start><end>(?=;|{)</end>
            <include>
                <context ref="types"/>
                <context id="type-custom-name" style-ref="special">
                    <match extended="true">\%{identifier-with-ns}</match>
                </context>
                <context ref="common"/>
            </include>
        </context>
        <context id="type-substatements">
            <start>{</start><end>(?=})</end>
            <include>
                <context ref="type"/>
                <context ref="type-properties"/>
                <context ref="common"/>
            </include>
        </context>
        <context ref="common"/>
    </include>
</context>
-->
    <xsl:template match="yang:statement">
        <context>
            <xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
            <xsl:if test="@once-only"><xsl:attribute name="once-only"><xsl:value-of select="@once-only"/></xsl:attribute></xsl:if>
            <start extended="true">\b<xsl:choose>
                <xsl:when test="yang:name-pattern">(<xsl:value-of select="yang:name-pattern"/>)</xsl:when>
                <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
            </xsl:choose>\b</start>
            <end>;|}</end> <!-- TODO exclude ; when at least a mandatory -->
            <include>
                <context sub-pattern="0" where="start">
                    <xsl:attribute name="style-ref"><xsl:value-of select="@style"/></xsl:attribute>
                </context>
                <context>
                    <xsl:attribute name="id"><xsl:value-of select="@name"/>-argument</xsl:attribute>
                    <xsl:if test="yang:argument/@style">
                        <xsl:attribute name="style-ref"><xsl:value-of select="yang:argument/@style"/></xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="yang:argument"/>
                </context>
                <context>
                    <xsl:attribute name="id"><xsl:value-of select="@name"/>-substatements</xsl:attribute>
                    <start>{</start><end>(?=})</end>
                    <include>
                        <xsl:apply-templates select="yang:substatement"/>
                        <context ref="common"/><!-- TODO extensions -->
                    </include>
                </context>
                <context ref="common"/><!-- TODO not extensions -->
            </include>
        </context>
    </xsl:template>
    
    <xsl:template match="yang:argument[@type='match']">
        <start extended="true"><xsl:value-of select="@pattern"/></start><end>(?=;|{)</end>
        <include>
            <context ref="common"/><!-- TODO not extensions -->
        </include>
    </xsl:template>
    
    <xsl:template match="yang:argument[@type='ref']">
        <start>\s+</start><end>(?=;|{)</end>
        <include>
            <context><xsl:attribute name="ref"><xsl:value-of select="@context"/></xsl:attribute></context>
        </include>
    </xsl:template>
    
    <xsl:template match="yang:argument[@type='multiple']">
        <start>\s+</start><end>(?=;|{)</end>
        <include>
            <xsl:for-each select="yang:argument">
                <xsl:choose>
                    <xsl:when test="@type='match'">
                        <context>
                            <xsl:attribute name="id"><xsl:value-of select="../../@name"/>-argument-match</xsl:attribute>
                            <xsl:attribute name="style-ref"><xsl:value-of select="@style"/></xsl:attribute>
                            <match extended="true"><xsl:value-of select="@pattern"/></match>
                        </context>
                    </xsl:when>
                    <xsl:when test="@type='ref'">
                        <context><xsl:attribute name="ref"><xsl:value-of select="@context"/></xsl:attribute></context>
                    </xsl:when>
                    <xsl:otherwise><ERROR/></xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <context ref="types"/>
            <context id="type-custom-name" style-ref="special">
                <match extended="true">\%{identifier-with-ns}</match>
            </context>
            <context ref="common"/><!-- TODO not extensions -->
        </include>
    </xsl:template>
    
    <xsl:template match="yang:substatement">
        <context><xsl:attribute name="ref"><xsl:value-of select="@name"/></xsl:attribute></context>
    </xsl:template>
    
    <xsl:template match="/yang:yang-statements">
<language id="yang" _name="YANG" version="2.0" _section="Others">
<metadata>
    <property name="mimetypes">application/yang</property>
    <property name="globs">*.yang</property>
    <property name="line-comment-start">//</property>
    <property name="block-comment-start">/*</property>
    <property name="block-comment-end">*/</property>
</metadata>
<styles>
    <style id="comment"           _name="Comment"               map-to="def:comment"/>
    <style id="doc-comment"       _name="Documentation comment" map-to="def:doc-comment"/>
    <style id="doc-stmt"          _name="Documentation statement" map-to="def:doc-comment-element"/>
    <style id="string"            _name="String"                map-to="def:string"/>
    <style id="number"            _name="Number"                map-to="def:number"/>
    <style id="keyword1"          _name="Keyword 1"             map-to="def:keyword"/>
    <style id="keyword2"          _name="Keyword 2"             map-to="def:statement"/>
    <style id="operator"          _name="Operator"              map-to="def:operator"/>
    <style id="type"              _name="Data Type"             map-to="def:type"/>
    <style id="special"           _name="Special"               map-to="def:special-constant"/>
    <style id="error"             _name="Error"                 map-to="def:error"/>
    <style id="mark"              _name="Debug mark"            map-to="def:underlined"/>
</styles>
<definitions>
    <!-- Common regular expressions -->
    <define-regex id="identifier-base" extended="true">[\w_][-\w_\.0-9]*</define-regex>
    <define-regex id="identifier" extended="true">['"]?\b\%{identifier-base}\b['"]?</define-regex>
    <define-regex id="identifier-with-ns" extended="true">\b['"]?(\%{identifier-base}:)?\%{identifier-base}['"]?\b</define-regex>
    <define-regex id="qualified-identifier" extended="true">\b['"]?\%{identifier-base}:\%{identifier-base}['"]?\b</define-regex>
    <define-regex id="date" extended="true">\b[0-9]{4}-[01][0-9]-[0-3][0-9]\b</define-regex>

    <!-- Comment the first line and uncomment the second to accept unknown statements -->
    <define-regex id="extension" extended="true">\%{qualified-identifier}</define-regex>
    <!--define-regex id="extension" extended="true">\%{identifier-with-ns}</define-regex-->

    <!-- Built-in types -->
    <context id="types" style-ref="type">
        <keyword>(u)?int(8|16|32|64)</keyword>
        <keyword>decimal64</keyword>
        <keyword>string</keyword>
        <keyword>boolean</keyword>
        <keyword>enumeration</keyword>
        <keyword>bits</keyword>
        <keyword>binary</keyword>
        <keyword>leafref</keyword>
        <keyword>identityref</keyword>
        <keyword>empty</keyword>
        <keyword>union</keyword>
        <keyword>instance-identifier</keyword>
    </context>

    <!-- Extensions -->
    <context id="extensions">
        <include>
            <context id="extension-simple">
                <match extended="true">\b(\%{extension})(\s+[^;{]+)?;</match>
                <include>
                    <context sub-pattern="1" style-ref="keyword2"/>
                </include>
            </context>
            <context id="extension-block">
                <start extended="true">\%{extension}</start>
                <end>}</end>
                <include>
                    <context sub-pattern="0" where="start" style-ref="keyword2"/>
                    <context ref="common"/>
                </include>
            </context>
        </include>
    </context>

    <!-- Parameter contexts -->
    <context id="string">
        <include>
            <context id="single-quoted-string" style-ref="string">
                <start>'</start><end>'</end>
                <include><context ref="def:in-comment"/></include>
            </context>
            <context id="double-quoted-string" style-ref="string">
                <start>"</start><end>(?&lt;!\\)"</end>
                <include><context ref="def:in-comment"/></include>
            </context>
            <context id="unquoted-string" style-ref="string">
                <match extended="true">[^'";{}+\s]+(\s+[^+;{])?</match>
                <include>
                    <context sub-pattern="1" style-ref="error"/>
                </include>
            </context>
            <context id="concat-string" style-ref="operator">
                <match>\+</match>
            </context>
            <context ref="def:c-like-comment"/>
            <context ref="def:c-like-comment-multiline"/>
            <context ref="def:c-like-close-comment-outside-comment"/>
            <context ref="wserror"/>
        </include>
    </context>

    <!-- Other contexts -->
    <context id="wserror" style-ref="error">
        <match>\s+$</match>
    </context>

    <context id="stmt-error" style-ref="error">
        <match extended="true">\%{identifier-with-ns}</match>
    </context>

    <context id="common">
        <include>
            <context ref="def:c-like-comment"/>
            <context ref="def:c-like-comment-multiline"/>
            <context ref="def:c-like-close-comment-outside-comment"/>
            <context ref="extensions"/>
            <context ref="stmt-error"/>
            <context ref="wserror"/>
        </include>
    </context>
    
    <!-- Top-level statements -->
    <context id="module" once-only="true"> <!-- 7.1, 7.2 -->
        <start extended="true">\b(module|submodule)\s+(\%{identifier})</start>
        <end>}</end>
        <include>
            <context sub-pattern="1" where="start" style-ref="keyword1"/>
            <context sub-pattern="2" where="start" style-ref="special"/>
            <xsl:apply-templates select="yang:top-level/yang:substatement"/>
            <context ref="common"/>
        </include>
    </context>
    
    <!-- Other statements -->
    <xsl:apply-templates select="yang:statement"/>

    <!-- Main context -->
    <context id="yang" class="no-spell-check">
        <include>
            <context ref="def:c-like-comment"/>
            <context ref="def:c-like-comment-multiline"/>
            <context ref="def:c-like-close-comment-outside-comment"/>
            <context ref="module"/>
            <context ref="stmt-error"/>
            <context ref="wserror"/>
        </include>
    </context>
  </definitions>
</language>
    </xsl:template>
</xsl:stylesheet>
