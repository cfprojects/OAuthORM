<cfcomponent accessors="true" output="false" hint="oAuthResponseService">

<cffunction name="hasToken" returntype="boolean" access="public" output="false" hint="Checks whether the response a successfull requestToken request or not">
	<cfargument name="httpResponse" type="string" required="true" hint="HTTP response" />

	<cfreturn findNoCase('oauth_token',arguments.httpResponse) />
</cffunction>


<cffunction name="getTokenValues" returntype="struct" access="public" output="false" hint="Gets the request token from a given http response">
	<cfargument name="httpResponse" type="string" required="true" hint="HTTP response" />

	<cfreturn { 'key'=listLast(listFirst(arguments.httpResponse,'&'),'='),'secret'=listLast(listLast(arguments.httpResponse,'&'),'=') } />
</cffunction>


<cffunction name="toAccessTokenURL" returntype="string" access="public" output="false" hint="Generates the access token url">
	<cfargument name="consumerKey"		type="string"	required="true"		hint="Consumer key" />
	<cfargument name="consumerSecret"	type="string"	required="true"		hint="Consumer secret" />
	<cfargument name="tokenKey"				type="string"	required="true"		hint="Token key" />
	<cfargument name="tokenSecret"		type="string"	required="true"		hint="Token secret" />
	<cfargument name="endpoint"				type="string"	required="true"		hint="Authorization endpoint url" />
	<cfargument name="callback"				type="string"	required="true"		hint="Callback URL" />
	<cfargument name="params"					type="struct"	required="false"	default="#structNew()#"	hint="Additional callback params" />

	<cfset local.callback = '#arguments.callback#?key=#arguments.consumerKey#&secret=#arguments.consumerSecret#&token=#arguments.tokenKey#&token_secret=#arguments.tokenSecret#&endpoint=#urlEncodedFormat(arguments.endpoint)#' />
	<cfloop collection="#arguments.params#" item="local.key">
		<cfset local.callback = listAppend(local.callback,'#local.key#=#urlEncodedFormat(arguments.params[local.key])#','&') />
	</cfloop>

	<cfreturn '#arguments.endpoint#?oauth_token=#arguments.tokenKey#&oauth_callback=#urlEncodedFormat(local.callback)#' />
</cffunction>

</cfcomponent>