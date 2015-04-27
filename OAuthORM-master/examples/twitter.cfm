<cfset local.oAuthRequestService		= application.oAuthRequestService />
<cfset local.oAuthResponseService		= application.oAuthResponseService />


<cfset local.consumerKey						= '' />	<!--- insert your twitter consumer key --->
<cfset local.consumerSecret					= '' />	<!--- insert your twitter consumer secret --->
<cfset local.tokenEndpoint					= 'https://api.twitter.com/oauth/request_token' />
<cfset local.authorizationEndpoint	= 'https://api.twitter.com/oauth/authorize' />
<cfset local.callbackURL						= 'www.somesite.com/mashup/authorize.cfm' />


<cfset local.oAuthRequest = local.oAuthRequestService.fromConsumer(consumer=local.consumerKey,httpURL=local.tokenEndpoint,httpMethod='GET') />
<cfset local.oAuthRequest = local.oAuthRequestService.sign(local.oAuthRequest,local.consumerSecret) />
<cfset local.requestURL		= local.oAuthRequestService.toURL(oAuthRequest=local.oAuthRequest) />

<cfhttp url="#local.requestURL#" method="get" result="local.tokenResponse" />


<cfif local.oAuthResponseService.hasToken(local.tokenResponse.fileContent)>
	<cfset local.token = local.oAuthResponseService.getTokenValues(local.tokenResponse.fileContent) />

	<cfset local.accessTokenURL = local.oAuthResponseService.toAccessTokenURL(
		consumerKey=local.consumerKey,
		consumerSecret=local.consumerSecret,
		tokenKey=local.token.key,
		tokenSecret=local.token.secret,
		endpoint=local.authorizationEndpoint,
		callback=local.callbackURL
	) />

	<cflocation url="#local.accessTokenURL#" addToken="false" />
<cfelse>
	<cfdump var="#local.tokenResponse#">
</cfif>