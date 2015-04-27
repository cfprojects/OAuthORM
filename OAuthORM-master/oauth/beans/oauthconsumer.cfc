<cfcomponent accessors="true" output="false" persistent="true" hint="oAuthConsumerBean">

<cfproperty name="ident"			ormType="string"		notNull="true"	length="36"	fieldType="id"	generator="guid"	hint="Unique primary key" />
<cfproperty name="createdat"	ormType="timestamp"	notNull="true"	hint="Time of creation" />
<cfproperty name="name"				ormType="string"		notNull="true"	length="20"	hint="Name of the consumer" />
<cfproperty name="fullname"		ormType="string"		notNull="true"	length="50"	hint="Fullname of the consumer" />
<cfproperty name="email"			ormType="string"		notNull="true"	length="50"	hint="Email of the consumer" />
<cfproperty name="key"				ormType="string"		notNull="true"	unique="true"	length="50"	hint="Key of the consumer" />
<cfproperty name="secret"			ormType="string"		notNull="true"	unique="true"	length="50"	hint="Secret of the consumer" />
<cfproperty name="hasxauth"		ormType="boolean"		boolean="true"	default="false"	dbDefault="0"	hint="If xAuth authorization is allowed for the consumer" />


<cffunction name="preInsert" returntype="void" access="public" output="false" hint="Executes before insert">
	<cfif isNull(variables.createdAt)><cfset variables.createdAt = now() /></cfif>
</cffunction>

</cfcomponent>
