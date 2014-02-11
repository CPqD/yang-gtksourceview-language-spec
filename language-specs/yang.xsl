<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:yang="http://cpqd.com.br/yang/gtksourceview-3.0-styles">
    
    <xsl:template match="yang:statement">
        <context>
            <xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
            <xsl:if test="@once-only"><xsl:attribute name="once-only"><xsl:value-of select="@once-only"/></xsl:attribute></xsl:if>
            <start extended="true">\b<xsl:choose>
                <xsl:when test="yang:name-pattern">(<xsl:value-of select="yang:name-pattern"/>)</xsl:when>
                <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
            </xsl:choose>\b</start>
            <end><xsl:if test="not(yang:substatement[@mandatory='true'])">;|</xsl:if>}</end>
            <include>
                <context sub-pattern="0" where="start">
                    <xsl:attribute name="style-ref"><xsl:value-of select="@style"/></xsl:attribute>
                </context>
                <xsl:if test="yang:argument">
                    <context>
                        <xsl:attribute name="id"><xsl:value-of select="@name"/>-argument</xsl:attribute>
                        <xsl:if test="yang:argument/@style">
                            <xsl:attribute name="style-ref"><xsl:value-of select="yang:argument/@style"/></xsl:attribute>
                        </xsl:if>
                        <xsl:apply-templates select="yang:argument"/>
                    </context>
                </xsl:if>
                <context>
                    <xsl:attribute name="id"><xsl:value-of select="@name"/>-substatements</xsl:attribute>
                    <start>{</start><end>(?=})</end>
                    <include>
                        <xsl:apply-templates select="yang:substatement"/>
                        <context ref="extensions"/>
                        <context ref="common"/>
                    </include>
                </context>
                <context ref="common"/>
            </include>
        </context>
    </xsl:template>
    
    <xsl:template match="yang:group">
        <context>
            <xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
            <include>
                <xsl:apply-templates select="yang:substatement"/>
            </include>
        </context>
    </xsl:template>

    <xsl:template match="yang:argument[@type='match']">
        <start extended="true"><xsl:value-of select="@pattern"/></start><end>(?=;|{)</end>
        <include>
            <context ref="common"/>
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
            <context ref="common"/>
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

    <!-- Extensions -->
    <context id="extensions">
        <start extended="true">\%{extension}</start><end>;|}</end>
        <include>
            <context sub-pattern="0" where="start" style-ref="keyword2"/>
            <context id="extensions-argument"><!-- no style for extension argument -->
                <start>\s+</start><end>(?=;|{)</end>
            </context>
            <context id="extensions-substatements">
                <start>{</start><end>(?=;|})</end>
                <include>
                    <context ref="any-statement"/>
                    <context ref="common"/>
                </include>
            </context>
            <context ref="common"/>
        </include>
    </context>
    <context id="any-statement">
        <start extended="true">\%{identifier-with-ns}</start><end>;|}</end>
        <include>
            <context sub-pattern="0" where="start" style-ref="keyword2"/>
            <context id="any-statement-argument"><!-- no style for argument -->
                <start>\s+</start><end>(?=;|{)</end>
            </context>
            <context id="any-statement-substatements">
                <start>{</start><end>(?=;|})</end>
                <include>
                    <context ref="any-statement"/>
                    <context ref="common"/>
                </include>
            </context>
            <context ref="common"/>
        </include>
    </context>

    <!-- Argument contexts -->
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

    <context id="boolean" style-ref="special">
        <keyword>false</keyword>
        <keyword>true</keyword>
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
            <context ref="extensions"/>
            <context ref="common"/>
        </include>
    </context>
    
    <!-- Other statements -->
    <xsl:apply-templates select="yang:statement|yang:group"/>

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
