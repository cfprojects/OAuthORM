<cfcomponent accessors="true" output="false" hint="oAuthUtilService">

<cffunction name="init" returntype="any" access="public" output="false" hint="Constructor">
	<cfset variables.urlEncoder	= createObject('java','java.net.URLEncoder') />
	<cfset variables.urlDecoder	= createObject('java','java.net.URLDecoder') />

	<cfreturn this />
</cffunction>


<cffunction name="generateTimestamp" returntype="numeric" access="public" output="false" hint="Generates the timestamp">
	<cfreturn int(getTickCount() / 1000) />
</cffunction>


<cffunction name="generateNonce" returntype="string" access="public" output="false" hint="Generates a nonce">
	<cfreturn hash('#generateTimestamp()##randRange(0,createObject('java','java.lang.Integer').MAX_VALUE)#','SHA') />
</cffunction>


<cffunction name="generateKey" returntype="string" access="public" output="false" hint="Generates a key">
	<cfreturn hash('#generateTimestamp()##createUUID()#','SHA') />
</cffunction>


<cffunction name="generateSecret" returntype="string" access="public" output="false" hint="Generates a secret">
	<cfreturn hash(hash('#generateTimestamp()##createUUID()#','SHA'),'SHA') />
</cffunction>


<cffunction name="encode" returntype="string" access="public" output="false" hint="Encodes a given string in RFC 3986">
	<cfargument name="str"			type="string"	required="true"		default=""	hint="String to encode" />
	<cfargument name="charset"	type="string"	required="false"	default="utf-8"	hint="Charset used for the encoding" />

	<cfset arguments.str	= variables.urlEncoder.encode(javaCast('string',arguments.str),javaCast('string',arguments.charset)) />
	<cfset arguments.str	= replace(arguments.str,'+','%20','all') />
	<cfset arguments.str	= replace(arguments.str,'*','%2A','all') />
	<cfset arguments.str	= replace(arguments.str,'%7E','~','all') />

	<cfreturn arguments.str />
</cffunction>


<cffunction name="decode" returntype="string" access="public" output="false" hint="Encodes a given string in RFC 3986">
	<cfargument name="str"			type="string"	required="true"		default=""	hint="String to encode" />
	<cfargument name="charset"	type="string"	required="false"	default="utf-8"	hint="Charset used for the encoding" />

	<cfreturn variables.urlDecoder.decode(javaCast('string',arguments.str),javaCast('string',arguments.charset)) />
</cffunction>

</cfcomponent>