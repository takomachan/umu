<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0"
>
	<xsl:import href="/opt/local/share/xsl/docbook-xsl/epub/docbook.xsl"/>
	<xsl:output method="html" encoding="UTF-8" indent="no"/>

	<xsl:param name="callouts.extension"	select="1"></xsl:param>
	<xsl:param name="callout.graphics"		select="0"></xsl:param>
	<xsl:param name="callout.unicode"		select="1"></xsl:param>
	<xsl:param name="callout.defaultcolumn">60</xsl:param>
</xsl:stylesheet>
