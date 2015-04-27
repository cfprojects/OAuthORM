<cfcomponent accessors="true" extends="parent.orm" output="false" hint="oAuthConsumerService">

<cfproperty name="oAuthUtilService" />


<cffunction name="init" returntype="any" access="public" output="false" hint="Constructor">
	<cfreturn super.init('oauthconsumer') />
</cffunction>


<cffunction name="loadByKey" returntype="any" access="public" output="false" hint="Loads a consumer by its key">
	<cfargument name="key" type="string" required="true" hint="Key to use" />

	<cfif len(arguments.key)><cfreturn load({ key=arguments.key },true) /></cfif>
</cffunction>


<cffunction name="save" returntype="void" access="public" output="false" hint="Saves a given entity">
	<cfargument name="entity" type="any" required="true" hint="Entity to save" />

	<cfif isNull(arguments.entity.getKey())><cfset arguments.entity.setKey(getOAuthUtilService().generateKey()) /></cfif>
	<cfif isNull(arguments.entity.getSecret())><cfset arguments.entity.setSecret(getOAuthUtilService().generateSecret()) /></cfif>

	<cfset super.save(argumentCollection=arguments) />

</cffunction>

</cfcomponent>