<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0"
>
	<!-- xsl:import
		href="/usr/share/xsl/docbook-xsl/html/chunk.xsl"
	/-->
	<xsl:import
		href="/opt/local/share/xsl/docbook-xsl/html/chunk.xsl"
	/>

	<xsl:output method="html" encoding="UTF-8" indent="no"/>


	<xsl:param name="html.stylesheet">../../tmdoc.css</xsl:param>
	<xsl:param name="use.id.as.filename"			select="'1'"/>

	<xsl:param name="toc.max.depth"					select="'2'"/>
	<xsl:param name="generate.section.toc.level"	select="'2'"/>
	<xsl:param name="toc.section.depth"				select="'3'"/>
</xsl:stylesheet>
