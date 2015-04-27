<cfcomponent accessors="true" output="false" hint="oAuthServerService">

<cfproperty name="oAuthRequestService" />
<cfproperty name="oAuthUtilService" />
<cfproperty name="oAuthTokenService" />
<cfproperty name="oAuthConsumerService" />
<cfproperty name="timestampTimeout" />


<cffunction name="init" returntype="any" access="public" output="false" hint="Constructor">

	<cfset setTimestampTimeout(7200) />

	<cfreturn this />
</cffunction>


<cffunction name="fetchRequestToken" returntype="any" access="public" output="false" hint="Fetches a request token">
	<cfargument name="oAuthRequest" type="struct" required="false" default="#getOAuthRequestService().fromHTTPRequest()#" hint="oAuthRequest for which to fetch the request token" />

	<cfset local.requestToken = '' />

	<cfif getOAuthRequestService().verify(arguments.oAuthRequest,'request_token',getTimestampTimeout())>
		<cfset local.consumer			= getOAuthConsumerService().loadByKey(arguments.oAuthRequest.params.oauth_consumer_key) />
		<cfset local.requestToken	= getOAuthTokenService().new({ consumer=local.consumer,type='request' }) />
		<cfset getOAuthTokenService().save(local.requestToken) />
	</cfif>

	<cfreturn local.requestToken />
</cffunction>


<cffunction name="fetchAccessToken" returntype="any" access="public" output="false" hint="Fetches an access token">
	<cfargument name="oAuthRequest" type="struct" required="false" default="#getOAuthRequestService().fromHTTPRequest()#" hint="oAuthRequest for which to fetch the access token" />

	<cfif getOAuthRequestService().verify(arguments.oAuthRequest,'access_token',getTimestampTimeout())>
		<cfif arguments.oAuthRequest.authMode EQ 'oauth'>
			<cfset local.requestToken	= getOAuthTokenService().loadByKey(arguments.oAuthRequest.params.oauth_token) />
			<cfset getOAuthTokenService().delete(local.requestToken) />
		</cfif>

		<cfset local.consumer			= getOAuthConsumerService().loadByKey(arguments.oAuthRequest.params.oauth_consumer_key) />
		<cfset local.accessToken	= getOAuthTokenService().new({ consumer=local.consumer,type='access' }) />
		<cfset getOAuthTokenService().save(local.accessToken) />
	</cfif>

	<cfreturn local.accessToken />
</cffunction>

</cfcomponent>