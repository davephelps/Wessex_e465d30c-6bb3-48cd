<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dm="http://azure.workflow.datamapper" xmlns:ef="http://azure.workflow.datamapper.extensions" xmlns="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="xsl xs math dm ef" version="3.0" expand-text="yes">
  <xsl:output indent="yes" media-type="text/json" method="text" omit-xml-declaration="yes" />
  <xsl:template match="/">
    <xsl:variable name="xmlinput" select="json-to-xml(/)" />
    <xsl:variable name="xmloutput">
      <xsl:apply-templates select="$xmlinput" mode="azure.workflow.datamapper" />
    </xsl:variable>
    <xsl:value-of select="xml-to-json($xmloutput,map{'indent':true()})" />
  </xsl:template>
  <xsl:template match="/" mode="azure.workflow.datamapper">
    <map>
      <xsl:choose>
        <xsl:when test="local-name-from-QName(node-name(/*/*[@key='order']/*[@key='orderId'])) = 'null'">
          <null key="orderId" />
        </xsl:when>
        <xsl:otherwise>
          <string key="orderId">{/*/*[@key='order']/*[@key='orderId']}</string>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="local-name-from-QName(node-name(/*/*[@key='account']/*[@key='accountId'])) = 'null'">
          <null key="accountId" />
        </xsl:when>
        <xsl:otherwise>
          <string key="accountId">{/*/*[@key='account']/*[@key='accountId']}</string>
        </xsl:otherwise>
      </xsl:choose>
      <string key="customerFullName">{concat(/*/*[@key='account']/*[@key='title'], ' ', /*/*[@key='order']/*[@key='forenames'], ' ', /*/*[@key='order']/*[@key='surname'])}</string>
      <array key="orderDetails">
        <xsl:for-each select="/*/*[@key='order']/*[@key='orderDetails']/*">
          <map>
            <xsl:choose>
              <xsl:when test="local-name-from-QName(node-name(*[@key='quantity'])) = 'null'">
                <null key="quantity" />
              </xsl:when>
              <xsl:otherwise>
                <string key="quantity">{*[@key='quantity']}</string>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="local-name-from-QName(node-name(*[@key='price'])) = 'null'">
                <null key="price" />
              </xsl:when>
              <xsl:otherwise>
                <string key="price">{*[@key='price']}</string>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="local-name-from-QName(node-name(*[@key='productDetails']/*[@key='productID'])) = 'null'">
                <null key="productID" />
              </xsl:when>
              <xsl:otherwise>
                <string key="productID">{*[@key='productDetails']/*[@key='productID']}</string>
              </xsl:otherwise>
            </xsl:choose>
            <string key="orderTotal">{(*[@key='price']) * (*[@key='quantity'])}</string>
          </map>
        </xsl:for-each>
      </array>
      <string key="totalOrderQuantity">{sum(/*/*[@key='order']/*[@key='orderDetails']/*/(*[@key='quantity']))}</string>
      <string key="totalOrderValue">{sum(/*/*[@key='order']/*[@key='orderDetails']/*/((*[@key='price']) * (*[@key='quantity'])))}</string>
    </map>
  </xsl:template>
</xsl:stylesheet>