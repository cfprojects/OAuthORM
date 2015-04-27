<cfcomponent output="false">

<cfset this.name								= hash(getCurrentTemplatePath()) />
<cfset this.mappings['/oauth']	= '#getDirectoryFromPath(getCurrentTemplatePath())#oauth' />
<cfset this.datasource					= 'oauth' />
<cfset this.ormEnabled					= true />
<cfset this.ormSettings					= { dbCreate='update',cfcLocation='oauth/beans',eventHandling=true } />


<cffunction name="onRequestStart" output="false" returntype="void">
	<cfif structKeyExists(url,'ormReload')><cfset ormReload() /></cfif>
	<cfset init() />
	<cfset ioc() />
</cffunction>


<cffunction name="init" returntype="void" access="private" output="false" hint="Initializes all objects">
	<cfset application.oAuthUtilService			= new oauth.services.oauthutil() />
	<cfset application.oAuthConsumerService	= new oauth.services.oauthconsumer() />
	<cfset application.oAuthTokenService 		= new oauth.services.oauthtoken() />
	<cfset application.oAuthResponseService = new oauth.services.oauthresponse() />
	<cfset application.oAuthRequestService 	= new oauth.services.oauthrequest() />
	<cfset application.oAuthServerService 	= new oauth.services.oauthserver() />
</cffunction>


<cffunction name="ioc" returntype="void" access="private" output="false" hint="Dependency injection">
	<cfset application.oAuthTokenService.setOAuthUtilService(application.oAuthUtilService) />

	<cfset application.oAuthRequestService.setOAuthUtilService(application.oAuthUtilService) />
	<cfset application.oAuthRequestService.setOAuthConsumerService(application.oAuthConsumerService) />
	<cfset application.oAuthRequestService.setOAuthTokenService(application.oAuthTokenService) />

	<cfset application.oAuthServerService.setOAuthRequestService(application.oAuthRequestService) />
	<cfset application.oAuthServerService.setOAuthConsumerService(application.oAuthConsumerService) />
	<cfset application.oAuthServerService.setOAuthUtilService(application.oAuthUtilService) />
	<cfset application.oAuthServerService.setOAuthTokenService(application.oAuthTokenService) />
</cffunction>


<cffunction name="data" returntype="void" access="private" output="false" hint="Inserts the testdata if necessary">
	<cfif arrayIsEmpty(application.oAuthConsumerService.load())>
		<cfset local.testConsumer = application.oAuthConsumerService.new({ name='testConsumer',fullName='Consumer for testing purposes',email='test@oauth.local',key='CONSUMER_KEY',secret='CONSUMER_SECRET' }) />
		<cfset application.oAuthConsumerService.save(local.testConsumer) />
		<cfset ormFlush() />
	</cfif>
</cffunction>

</cfcomponent>
