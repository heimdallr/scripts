<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="yes"/>
	<xsl:template match="/">
		<xsl:element name="TS">

			<xsl:attribute name="version">
				<xsl:value-of select="TS/@version" />
			</xsl:attribute>
			<xsl:attribute name="language">
				<xsl:value-of select="TS/@language" />
			</xsl:attribute>

			<xsl:for-each select="/TS/context">
				<xsl:element name="context">
					<xsl:text>&#xa;&#9;</xsl:text>
					<xsl:element name="name">
						<xsl:value-of select="name"/>
					</xsl:element>

					<xsl:for-each select="message">
						<xsl:sort select="source" order="ascending"/>

						<xsl:text>&#xa;&#9;</xsl:text>
						<xsl:element name="message">

							<xsl:text>&#xa;&#9;&#9;</xsl:text>
							<xsl:element name="source">
								<xsl:value-of select="source"/>
							</xsl:element>

							<xsl:text>&#xa;&#9;&#9;</xsl:text>
							<xsl:element name="translation">
								<xsl:choose>
									<xsl:when test="translation/@type">
										<xsl:attribute name="type">
											<xsl:value-of select="translation/@type" />
										</xsl:attribute>
									</xsl:when>
								</xsl:choose>							
								<xsl:value-of select="translation"/>
							</xsl:element>

						<xsl:text>&#xa;&#9;</xsl:text>
						</xsl:element>

					</xsl:for-each>

				</xsl:element>
			</xsl:for-each>

		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
