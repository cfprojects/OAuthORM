<cfcomponent accessors="true" extends="parent.orm" output="false" hint="oAuthTokenService">

<cfproperty name="oAuthUtilService" />


<cffunction name="init" returntype="any" access="public" output="false" hint="Constructor">
	<cfreturn super.init('oauthtoken') />
</cffunction>


<cffunction name="loadByNonce" returntype="any" access="public" output="false" hint="Loads a token by its nonce">
	<cfargument name="nonce" type="string" required="true" hint="Nonce to use" />

	<cfif len(arguments.nonce)><cfreturn load({ nonce=arguments.nonce },true) /></cfif>
</cffunction>


<cffunction name="loadByKey" returntype="any" access="public" output="false" hint="Loads a token by its key">
	<cfargument name="key" type="string" required="true" hint="Key to use" />

	<cfif len(arguments.key)><cfreturn load({ key=arguments.key },true) /></cfif>
</cffunction>


<cffunction name="save" returntype="void" access="public" output="false" hint="Saves a given token">
	<cfargument name="token" type="any" required="true" hint="Token to save" />

	<cfif isNull(arguments.token.getKey())><cfset arguments.token.setKey(getOAuthUtilService().generateKey()) /></cfif>
	<cfif isNull(arguments.token.getSecret())><cfset arguments.token.setSecret(getOAuthUtilService().generateSecret()) /></cfif>
	<cfif isNull(arguments.token.getNonce())><cfset arguments.token.setNonce(getOAuthUtilService().generateNonce()) /></cfif>
	<cfif isNull(arguments.token.getTimestamp())><cfset arguments.token.setTimestamp(getOAuthUtilService().generateTimestamp()) /></cfif>
	<cfset super.save(arguments.token) />
</cffunction>


<cffunction name="toString" returntype="string" access="public" output="false" hint="Generates the basic string serialization of a token that a server would respond to request_token and access_token calls with">
	<cfargument name="token" type="any" required="true" hint="Token to serialize" />

	<cfreturn 'oauth_token=#getOAuthUtilService().encode(arguments.token.getKey())#&oauth_token_secret=#getOAuthUtilService().encode(arguments.token.getSecret())#' />
</cffunction>

</cfcomponent>