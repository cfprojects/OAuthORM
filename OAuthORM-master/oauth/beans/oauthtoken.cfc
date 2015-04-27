<cfcomponent accessors="true" output="false" persistent="true" hint="oAuthTokenBean">

<cfproperty name="ident"			ormType="string"		notNull="true"	length="36"	fieldType="id"	generator="guid"	hint="Unique primary key" />
<cfproperty name="createdat"	ormType="timestamp"	notNull="true"	hint="Time of creation" />
<cfproperty name="type"				ormType="string"		notNull="true"	length="10"	hint="Type of the token (request,access)" />
<cfproperty name="key"				ormType="string"		notNull="true"	length="50"	unique="true"	hint="Key of the token" />
<cfproperty name="secret"			ormType="string"		notNull="true"	length="50"	unique="true"	hint="Secret of the token" />
<cfproperty name="nonce"			ormType="string"		notNull="true"	length="50"	hint="Nonce of the token" />
<cfproperty name="timestamp"	ormType="long"			notNull="true"	hint="Timestamp of the token" />
<cfproperty name="verifier"		ormType="string"		hint="OAuth verifier (used to grant access token)" />

<cfproperty name="consumer"	fieldType="many-to-one" cfc="oauth.beans.oauthconsumer"	fkColumn="consumer"	lazy="true" />


<cffunction name="preInsert" returntype="void" access="public" output="false" hint="Executes before insert">
	<cfif isNull(variables.createdAt)><cfset variables.createdAt = now() /></cfif>
</cffunction>


<cffunction name="setType" returntype="void" access="public" output="false" hint="Sets the type of the token">
	<cfargument name="type" type="string" required="true" hint="Type of the token to set" />

	<cfif listFindNoCase('request,access',arguments.type)>
		<cfset variables.type = lCase(arguments.type) />
	</cfif>
</cffunction>


<cffunction name="hasConsumer" returntype="boolean" access="public" output="false" hint="Check if there is a consumer present">	<!--- docu:MarcoBetschart/ 2012.07.31 16:07:35 PM - native method did not work in Railo 3.3 :( --->
	<cfargument name="consumer" type="any" required="false" default="" hint="Consumer to look for" />

	<cfset local.has = false />

	<cfif NOT isNull(variables.consumer)>
		<cfif isSimpleValue(arguments.consumer) AND len(arguments.consumer)>
			<cfset local.has = NOT compare(arguments.consumer,variables.consumer.getIdent()) />

		<cfelseif isInstanceOf(arguments.consumer,'oauthconsumer')>
			<cfset local.has = NOT compare(arguments.consumer.getIdent(),variables.consumer.getIdent()) />
		</cfif>
	</cfif>

	<cfreturn local.has />
</cffunction>

</cfcomponent>