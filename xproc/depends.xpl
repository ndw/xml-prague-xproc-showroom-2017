<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:c="http://www.w3.org/ns/xproc-step"
	        xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:ex="http://nwalsh.com/ns/xproc/steps"
                xmlns:dep="http://nwalsh.com/ns/depends"
                xmlns:pxf="http://exproc.org/proposed/steps/file"
                exclude-inline-prefixes="p c cx ex dep pxf"
                name="main" type="ex:out-of-date">
<p:input port="source"/>
<p:output port="result" sequence="true"/>

<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

<p:declare-step type="ex:ignore-up-to-date" name="main">
  <p:input port="source"/>
  <p:output port="result" sequence="true"/>

  <p:declare-step type="ex:bool" name="main">
    <p:output port="result"/>
    <p:option name="bool" required="true"/>
    <p:template>
      <p:input port="source"><p:empty/></p:input>
      <p:input port="template">
        <p:inline><c:result>{$bool}</c:result></p:inline>
      </p:input>
      <p:with-param name="bool" select="$bool"/>
    </p:template>
  </p:declare-step>

  <pxf:info fail-on-error="false">
    <p:with-option name="href"
                   select="resolve-uri(dep:depends/dep:target,
                                       base-uri(/dep:depends/dep:target))"/>
  </pxf:info>

  <p:choose name="info">
    <p:when test="/c:file">
      <p:output port="result"/>
      <p:variable name="tdate" select="/c:file/@last-modified"/>
      <p:for-each>
        <p:iteration-source select="/dep:depends/dep:source">
          <p:pipe step="main" port="source"/>
        </p:iteration-source>
        <pxf:info fail-on-error="false">
          <p:with-option name="href"
                         select="resolve-uri(/dep:source, base-uri(/dep:source))"/>
          <p:log port="result" href="/tmp/sources.log"/>
        </pxf:info>
        <p:choose>
          <p:when test="/c:file">
            <p:choose>
              <p:when test="/c:file/@last-modified &gt; $tdate">
                <ex:bool bool="0"/>
              </p:when>
              <p:otherwise>
                <ex:bool bool="1"/>
              </p:otherwise>
            </p:choose>
          </p:when>
          <p:otherwise>
            <ex:bool bool="0"/>
          </p:otherwise>
        </p:choose>
      </p:for-each>

      <p:wrap-sequence wrapper="sources"/>

      <p:choose>
        <p:when test="/sources/c:result = 0">
          <p:identity>
            <p:input port="source">
              <p:pipe step="main" port="source"/>
            </p:input>
          </p:identity>
        </p:when>
        <p:otherwise>
          <p:identity>
            <p:input port="source">
              <p:empty/>
            </p:input>
          </p:identity>
        </p:otherwise>
      </p:choose>
    </p:when>
    <p:otherwise>
      <p:output port="result"/>
      <p:identity>
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
</p:declare-step>

<p:for-each>
  <p:iteration-source select="/dep:dependencies/dep:depends"/>
  <ex:ignore-up-to-date/>
</p:for-each>

</p:declare-step>
