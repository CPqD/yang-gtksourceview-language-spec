all: yang.lang

yang.lang: yang.xml yang.xsl
	xsltproc yang.xsl $< > $@
#TODO remove wrong xmlns from generated file
