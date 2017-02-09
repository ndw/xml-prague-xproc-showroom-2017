<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:ex="http://nwalsh.com/ns/xproc/steps"
                xmlns:dep="http://nwalsh.com/ns/depends"
                exclude-inline-prefixes="c dep cx ex"
                name="main">
<p:input port="source"/>
<p:input port="parameters" kind="parameter"/>
<p:output port="result"/>
<p:serialization port="result" indent="true"/>

<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
<p:import href="depends.xpl"/>

<ex:out-of-date/>

<p:for-each name="update">
  <p:output port="result">
    <p:pipe step="store" port="result"/>
  </p:output>

  <p:load name="source">
    <p:with-option name="href"
                   select="resolve-uri(dep:depends/dep:source[1],
                                       base-uri(/dep:depends/dep:source[1]))">
      <p:pipe step="update" port="current"/>
    </p:with-option>
  </p:load>

  <p:load name="stylesheet">
    <p:with-option name="href"
                   select="resolve-uri(dep:depends/dep:source[2],
                                       base-uri(/dep:depends/dep:source[2]))">
      <p:pipe step="update" port="current"/>
    </p:with-option>
  </p:load>

  <p:xslt name="format">
    <p:input port="source">
      <p:pipe step="source" port="result"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe step="stylesheet" port="result"/>
    </p:input>
  </p:xslt>

  <p:count/>

  <p:choose name="store">
    <p:when test="string(/c:result) = '0'">
      <p:output port="result"/>
      <p:template>
        <p:input port="template">
          <p:inline><c:result empty="true">{$input}</c:result></p:inline>
        </p:input>
        <p:with-param name="input"
                      select="resolve-uri(dep:depends/dep:target[1],
                                          base-uri(/dep:depends/dep:target[1]))">
          <p:pipe step="update" port="current"/>
        </p:with-param>
      </p:template>
    </p:when>
    <p:otherwise>
      <p:output port="result">
        <p:pipe step="write-xhtml" port="result"/>
      </p:output>
      <p:store name="write-xhtml" method="xhtml">
        <p:input port="source">
          <p:pipe step="format" port="result"/>
        </p:input>
        <p:with-option name="href"
                       select="resolve-uri(dep:depends/dep:target[1], base-uri(/dep:depends/dep:target[1]))">
          <p:pipe step="update" port="current"/>
        </p:with-option>
      </p:store>
    </p:otherwise>
  </p:choose>
</p:for-each>

<p:wrap-sequence wrapper="c:wrapper"/>

</p:declare-step>
