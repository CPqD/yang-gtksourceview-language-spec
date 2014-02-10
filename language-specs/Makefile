all: yang.lang

yang.lang: yang.xml yang.xsl
	xsltproc yang.xsl $< > $@
	sed -i 's/xmlns[^=]*="[^"]*" //' $@

