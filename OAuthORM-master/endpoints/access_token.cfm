<cfset local.oAuthRequestService	= application.oAuthRequestService />
<cfset local.oAuthServerService		= application.oAuthServerService />
<cfset local.oAuthTokenService		= application.oAuthTokenService />


<cfset local.oAuthRequest	= local.oAuthRequestService.fromHTTPRequest(httpURL='http://#cgi.http_host##cgi.script_name#') />
<cfset local.accessToken	= local.oAuthServerService.fetchAccessToken(local.oAuthRequest) />


<cfoutput>#local.oAuthTokenService.toString(local.accessToken)#</cfoutput>