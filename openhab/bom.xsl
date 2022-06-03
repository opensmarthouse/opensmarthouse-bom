<?xml version="1.0" encoding="utf-8" ?>
<!--

    Copyright (c) 2022-2022 Contributors to the OpenSmartHouse project

    See the NOTICE file(s) distributed with this work for additional
    information.

    This program and the accompanying materials are made available under the
    terms of the Eclipse Public License 2.0 which is available at
    http://www.eclipse.org/legal/epl-2.0

    SPDX-License-Identifier: EPL-2.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pom="http://maven.apache.org/POM/4.0.0" exclude-result-prefixes="pom">

  <!--
  This basic transformation set allows to generate "compat" feature set which allows to run standard
  OH bindings with OSH. Entire thing is generating "openhab-xyz" feature which refer source feature
  "opensmarthouse-xyz".
  -->
  <xsl:output method="xml" encoding="utf-8" indent="yes" />

  <xsl:param name="BOM_PARENT_GROUP_ID" />
  <xsl:param name="BOM_PARENT_ARTIFACT_ID" />
  <xsl:param name="BOM_VERSION" />

  <xsl:param name="VERSION" />
  <xsl:param name="RESULT_GROUP_ID" />

  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- override parent coordinates -->
  <xsl:template match="pom:parent">
    <xsl:element name="parent" namespace="{namespace-uri()}">
      <xsl:element name="groupId" namespace="{namespace-uri()}">
        <xsl:value-of select="$BOM_PARENT_GROUP_ID" />
      </xsl:element>
      <xsl:element name="artifactId" namespace="{namespace-uri()}">
        <xsl:value-of select="$BOM_PARENT_ARTIFACT_ID" />
      </xsl:element>
      <xsl:element name="version" namespace="{namespace-uri()}">
        <xsl:value-of select="$BOM_VERSION" />
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- inject custom groupId -->
  <xsl:template match="pom:project/pom:artifactId">
    <xsl:element name="groupId" namespace="{namespace-uri()}">
      <xsl:value-of select="$RESULT_GROUP_ID" />
    </xsl:element>
    <xsl:element name="artifactId" namespace="{namespace-uri()}">
      <xsl:value-of select="//pom:project/pom:artifactId" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="pom:dependencies|pom:dependencyManagement/pom:dependencies">
    <xsl:element name="dependencyManagement" namespace="{namespace-uri()}">

      <xsl:copy>
        <xsl:apply-templates select="pom:dependency"/>
      </xsl:copy>

    </xsl:element>
  </xsl:template>

  <xsl:template match="pom:dependency">
    <xsl:element name="dependency" namespace="{namespace-uri()}">
      <xsl:copy-of select="./pom:groupId" />
      <xsl:copy-of select="./pom:artifactId" />
      <xsl:element name="version" namespace="{namespace-uri()}">
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="pom:version"/>
          <xsl:with-param name="replace" select="'${project.version}'"/>
          <xsl:with-param name="by" select="$VERSION"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- string-replace-all from http://geekswithblogs.net/Erik/archive/2008/04/01/120915.aspx -->
  <xsl:template name="string-replace-all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text"
            select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>