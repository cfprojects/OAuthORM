<cfcomponent accessors="true" output="false" hint="oAuthRequestService">

<cfproperty name="oAuthUtilService" />
<cfproperty name="oAuthConsumerService" />
<cfproperty name="oAuthTokenService" />


<cffunction name="fromConsumer" returntype="struct" access="public" output="false" hint="Generates an oAuthRequest from a given consumer">
	<cfargument name="consumer"		type="any"		required="true"		hint="oAuthConsumerBean or oauth_consumer_key" />
	<cfargument name="httpURL"		type="string"	required="false"	default=""	hint="HTTP URL to use" />
	<cfargument name="httpMethod"	type="string"	required="false"	default=""	hint="HTTP method to use" />

	<cfset arguments.oauth_consumer_key = isObject(arguments.consumer) ? arguments.consumer.getKey() : arguments.consumer />
	<cfset structDelete(arguments,'consumer') />

	<cfreturn build(argumentCollection=arguments) />
</cffunction>


<cffunction name="fromConsumerAndToken" returntype="struct" access="public" output="false" hint="Generates an oAuthRequest from a given consumer and token">
	<cfargument name="consumer"		type="any"		required="true"		hint="oAuthConsumerBean or oauth_consumer_key" />
	<cfargument name="token"			type="any"		required="true"		hint="oAuthTokenBean or oauth_token" />
	<cfargument name="httpURL"		type="string"	required="false"	default=""	hint="HTTP URL to use" />
	<cfargument name="httpMethod"	type="string"	required="false"	default=""	hint="HTTP method to use" />

	<cfset arguments.oauth_consumer_key	= isObject(arguments.consumer) ? arguments.consumer.getKey() : arguments.consumer />
	<cfset arguments.oauth_token				= isObject(arguments.token) ? arguments.token.getKey() : arguments.token />

	<cfset structDelete(arguments,'consumer') />
	<cfset structDelete(arguments,'token') />

	<cfreturn build(argumentCollection=arguments) />
</cffunction>


<cffunction name="fromHTTPRequest" returntype="struct" access="public" output="false" hint="Gets the request from what was passed to the server">
	<cfargument name="httpURL"					type="string"	required="false"	default=""	hint="HTTP URL to use" />
	<cfargument name="httpRequestData"	type="struct"	required="false"	default="#getHTTPRequestData()#" hint="Request information" />

	<cfset local.args = structNew() />
	<cfset local.args['httpURL']						= arguments.httpURL />
	<cfset local.args['httpMethod']					= arguments.httpRequestData.method />
	<cfset local.args['oauth_consumer_key']	= '' />

	<cfif structKeyExists(arguments.httpRequestData.headers,'authorization') AND findNoCase('OAuth',arguments.httpRequestData.headers.authorization)>
		<cfset local.header = replaceNoCase(arguments.httpRequestData.headers.authorization,'OAuth ','') />
		<cfset local.params	= structNew() />

		<cfloop list="#local.header#" index="local.param">
			<cfset local.key = trim(getOAuthUtilService().decode(listFirst(local.param,'='))) />

			<cfif findNoCase('oauth',local.key)>
				<cfset local.params['#local.key#'] = trim(getOAuthUtilService().decode(replace(listLast(local.param,'='),'"','','all'))) />
			</cfif>
		</cfloop>

		<cfset structAppend(local.args,duplicate(local.params)) />
	</cfif>

	<cfset local.params	= structNew() />
	<cfif isDefined('FORM')>
		<cfset structAppend(local.params,duplicate(FORM)) />
		<cfset structDelete(local.params,'fieldNames') />
	</cfif>
	<cfif isDefined('URL')>
		<cfset structAppend(local.params,duplicate(URL)) />
	</cfif>
	<cfset structAppend(local.args,duplicate(local.params)) />

	<cfreturn build(argumentCollection=local.args) />
</cffunction>


<cffunction name="build" returntype="struct" access="public" output="false" hint="Builds up an OAuthRequest">
	<cfargument name="oauth_consumer_key"			type="string"		required="true"		hint="OAuth consumer key used" />
	<cfargument name="oauth_version"					type="string"		required="false"	default="1.0"	hint="OAuth version to use" />
	<cfargument name="oauth_nonce"						type="string"		required="false"	default="#getOAuthUtilService().generateNonce()#"	hint="OAuth nonce to use" />
	<cfargument name="oauth_timestamp"				type="string"		required="false"	default="#getOAuthUtilService().generateTimestamp()#"	hint="OAuth timestamp to use" />
	<cfargument name="oauth_signature_method"	type="string"		required="false"	default="HMAC-SHA1"	hint="OAuth signature method to use" />
	<cfargument name="oauth_signature"				type="string"		required="false"	default=""	hint="OAuth signature to use" />
	<cfargument name="oauth_token"						type="string"		required="false"	default=""	hint="OAuth Token to use" />
	<cfargument name="oauth_token_secret"			type="string"		required="false"	default=""	hint="OAuth token secret to use" />
	<cfargument name="oauth_callback"					type="string"		required="false"	default=""	hint="OAuth callback URL" />
	<cfargument name="oauth_verifier"					type="string"		required="false"	default=""	hint="OAuth verifier" />
	<cfargument name="x_auth_username"				type="string"		required="false"	default=""	hint="xAuth username" />
	<cfargument name="x_auth_password"				type="string"		required="false"	default=""	hint="xAuth password" />
	<cfargument name="x_auth_mode"						type="string"		required="false"	default=""	hint="xAuth mode" />
	<cfargument name="httpURL"								type="string"		required="false"	default=""	hint="HTTP URL to use" />
	<cfargument name="httpMethod"							type="string"		required="false"	default=""	hint="HTTP method to use" />

	<cfset local.oAuthRequest = { 'httpURL'='http://#cgi.http_host##cgi.script_name##cgi.path_info#','httpMethod'=cgi.request_method,'params'=structNew(),authMode='oauth' } />

	<cfif len(arguments.httpURL)>
		<cfset local.oAuthRequest.httpURL = replaceList(lCase(arguments.httpURL),':80,:443',',') />
	</cfif>
	<cfset local.oAuthRequest.httpMethod = uCase(arguments.httpMethod) />

	<cfset local.oAuthRequest.params['oauth_consumer_key']			= trim(arguments.oauth_consumer_key) />
	<cfset local.oAuthRequest.params['oauth_version']						= trim(arguments.oauth_version) />
	<cfset local.oAuthRequest.params['oauth_nonce']							= trim(arguments.oauth_nonce) />
	<cfset local.oAuthRequest.params['oauth_timestamp']					= trim(arguments.oauth_timestamp) />
	<cfset local.oAuthRequest.params['oauth_signature_method']	= trim(arguments.oauth_signature_method) />

	<cfloop list="oauth_signature,oauth_token,oauth_token_secret,oauth_callback,oauth_verifier,x_auth_username,x_auth_password,x_auth_mode" index="local.param">
		<cfif len(arguments[local.param])>
			<cfset local.oAuthRequest.params['#local.param#'] = trim(arguments[param]) />
		</cfif>
	</cfloop>

	<cfif len(arguments.oauth_token)>
		<cfset local.token = getOAuthTokenService().loadByKey(arguments.oauth_token) />
		<cfif NOT isNull(local.token)>
			<cfset local.oAuthRequest.params['oauth_token_secret'] = local.token.getSecret() />
		</cfif>
	</cfif>

	<cfif structKeyExists(local.oAuthRequest.params,'x_auth_mode')>
		<cfset local.oAuthRequest.authMode = 'xauth' />
	</cfif>

	<cfloop collection="#arguments#" item="local.key">
		<cfif NOT listFindNoCase('httpURL,httpMethod',local.key) AND NOT findNoCase('oauth_',local.key) AND NOT findNoCase('x_auth_',local.key)>
			<cfset local.oAuthRequest.params['#trim(lCase(local.key))#'] = arguments[local.key] />
		</cfif>
	</cfloop>

	<cfreturn local.oAuthRequest />
</cffunction>


<cffunction name="verify" returntype="boolean" access="public" output="false" hint="Verifies a given oAuthRequest">
	<cfargument name="oAuthRequest"	type="struct"		required="true"		hint="oAuthRequest to verify" />
	<cfargument name="requestType"	type="string"		required="false"	default="oauth"	hint="Type of request to verify: oauth,request_token,access_token" />
	<cfargument name="timeout"			type="numeric"	required="false"	default="7200"	hint="Timeout after which the timestamp is invalid" />

	<cfif NOT structKeyExists(arguments.oAuthRequest.params,'oauth_consumer_key')>
		<cfthrow type="OAuthException" message="oauth_consumer_key not provided" />
	</cfif>
	<cfset local.consumer = ensureConsumer(arguments.oAuthRequest.params.oauth_consumer_key) />

	<cfif arguments.oAuthRequest.authMode EQ 'xauth'>
		<cfif NOT local.consumer.getHasXAuth()>
			<cfthrow type="xAuthException" message="xAuth authentification method not allowed for consumer" />
		</cfif>

		<cfif NOT structKeyExists(arguments.oAuthRequest.params,'x_auth_mode')>
			<cfthrow type="xAuthException" message="x_auth_mode not provided" />
		</cfif>

		<cfif arguments.oAuthRequest.params.x_auth_mode EQ 'client_auth'>
			<cfif NOT structKeyExists(arguments.oAuthRequest.params,'x_auth_username')>
				<cfthrow type="xAuthException" message="x_auth_username not provided" />
			</cfif>

			<cfif NOT structKeyExists(arguments.oAuthRequest.params,'x_auth_password')>
				<cfthrow type="xAuthException" message="x_auth_password not provided" />
			</cfif>
		</cfif>

	<cfelseif arguments.requestType NEQ 'request_token'>
		<cfif NOT structKeyExists(arguments.oAuthRequest.params,'oauth_token')>
			<cfthrow type="OAuthException" message="oauth_token not provided" />
		</cfif>
		<cfset local.token = ensureToken(arguments.oAuthRequest.params.oauth_token) />

		<cfif NOT local.token.hasConsumer(local.consumer)>
			<cfthrow type="OAuthException" message="oauth_token/oauth_consumer_key mismatch" />
		</cfif>

		<cfif compare(local.token.getSecret(),arguments.oAuthRequest.params.oauth_token_secret)>
			<cfthrow type="OAuthException" message="oauth_signature is not valid" />
		</cfif>

		<cfif arguments.requestType EQ 'access_token'>
			<cfif NOT structKeyExists(arguments.oAuthRequest.params,'oauth_verifier')>
				<cfthrow type="OAuthException" message="oauth_verifier not provided" />
			</cfif>

			<cfif local.token.getVerifier() NEQ arguments.oAuthRequest.params.oauth_verifier>
				<cfthrow type="OAuthException" message="oauth_verifier is not valid" />
			</cfif>
		</cfif>
	</cfif>

	<cfif NOT structKeyExists(arguments.oAuthRequest.params,'oauth_timestamp')>
		<cfthrow type="OAuthException" message="oauth_timestamp not provided" />
	<cfelseif NOT isNumeric(arguments.oAuthRequest.params.oauth_timestamp) OR getOAuthUtilService().generateTimestamp() - arguments.oAuthRequest.params.oauth_timestamp GT arguments.timeout>
		<cfthrow type="OAuthException" message="oauth_timestamp is not valid" />
	</cfif>

	<cfif NOT structKeyExists(arguments.oAuthRequest.params,'oauth_nonce')>
		<cfthrow type="OAuthException" message="oauth_nonce not provided" />
	<cfelseif NOT isNull(getOAuthTokenService().loadByNonce(arguments.oAuthRequest.params.oauth_nonce))>
		<cfthrow type="OAuthException" message="oauth_nonce is not valid" />
	</cfif>

	<cfif NOT structKeyExists(arguments.oAuthRequest.params,'oauth_signature')>
		<cfthrow type="OAuthException" message="oauth_signature not provided" />

	<cfelse>
		<cfset local.remoteSignature	= arguments.oAuthRequest.params.oauth_signature />
		<cfset local.oAuthRequest			= sign(duplicate(arguments.oAuthRequest)) />
		<cfset local.localSignature 	= local.oAuthRequest.params.oauth_signature />

		<cfif compare(local.remoteSignature,local.localSignature)>
			<cfthrow type="OAuthException" message="oauth_signature is not valid." />
		</cfif>
	</cfif>

	<cfreturn true />
</cffunction>


<cffunction name="sign" returntype="struct" access="public" output="false" hint="Signs a given oAuthRequest">
	<cfargument name="oAuthRequest"		type="struct"	required="true"		hint="oAuthRequest to sign" />
	<cfargument name="consumerSecret"	type="string"	required="false"	default=""	hint="Consumer secret used to sign" />
	<cfargument name="tokenSecret"		type="string"	required="false"	default=""	hint="Token secret used to sign" />

	<cfset local.functionName = 'signWith#replace(arguments.oAuthRequest.params.oauth_signature_method,'-','_','all')#' />

	<cfif NOT structKeyExists(this,local.functionName)>
		<cfthrow type="OAuthException" message="Signature method not supported: #arguments.oAuthRequest.params.oauth_signature_method#" />
	</cfif>

	<cfif NOT len(arguments.consumerSecret)>
		<cfset arguments.consumerSecret = ensureConsumer(arguments.oAuthRequest.params.oauth_consumer_key).getSecret() />
	</cfif>

	<cfif NOT len(arguments.tokenSecret) AND structKeyExists(arguments.oAuthRequest.params,'oauth_token')>
		<cfif structKeyExists(arguments.oAuthRequest.params,'oauth_token_secret')>
			<cfset arguments.tokenSecret = arguments.oAuthRequest.params.oauth_token_secret />
		<cfelse>
			<cfset arguments.tokenSecret = ensureToken(arguments.oAuthRequest.params.oauth_token).getSecret() />
		</cfif>
	</cfif>

	<cfinvoke component="#this#" method="#local.functionName#" returnVariable="local.oAuthRequest">
		<cfinvokeargument name="oAuthRequest"		value="#duplicate(arguments.oAuthRequest)#" />
		<cfinvokeargument name="consumerSecret" value="#arguments.consumerSecret#" />
		<cfinvokeargument name="tokenSecret"		value="#arguments.tokenSecret#" />
	</cfinvoke>

	<cfreturn local.oAuthRequest />
</cffunction>


<cffunction name="signWithHMAC_SHA1" returntype="struct" access="public" output="false" hint="Signs a given oAuthRequest with the hmac-sha1 algorithm">
	<cfargument name="oAuthRequest"		type="struct"	required="true"		hint="oAuthRequest to sign" />
	<cfargument name="consumerSecret"	type="string"	required="false"	default=""	hint="Consumer secret used to sign" />
	<cfargument name="tokenSecret"		type="string"	required="false"	default=""	hint="Token secret used to sign" />

	<cfset local.message		= javaCast('string',toSignableString(arguments.oAuthRequest)).getBytes('iso-8859-1') />
	<cfset local.secretKey	= javaCast('string','#arguments.consumerSecret##chr(38)##arguments.tokenSecret#').getBytes('iso-8859-1') />
	<cfset local.spec 			= createObject('java','javax.crypto.spec.SecretKeySpec').init(local.secretKey,'HmacSHA1') />
	<cfset local.mac				= createObject('java','javax.crypto.Mac').getInstance(local.spec.getAlgorithm()) />

	<cfset local.mac.init(local.spec) />
	<cfset local.mac.update(local.message) />

	<cfset arguments.oAuthRequest.params['oauth_signature'] = toBase64(local.mac.doFinal()) />

	<cfreturn arguments.oAuthRequest />
</cffunction>


<cffunction name="signWithPlaintext" returntype="struct" access="public" output="false" hint="Signs a given oAuthRequest with plaintext">
	<cfargument name="oAuthRequest"		type="struct"	required="true"		hint="oAuthRequest to sign" />
	<cfargument name="consumerSecret"	type="string"	required="false"	default=""	hint="Consumer secret used to sign" />
	<cfargument name="tokenSecret"		type="string"	required="false"	default=""	hint="Token secret used to sign" />

	<cfset local.signature = getOAuthUtilService().encode(arguments.consumerSecret) />
	<cfif len(arguments.tokenSecret)>
		<cfset local.signature = getOAuthUtilService().encode(listAppend(local.signature,getOAuthUtilService().encode(arguments.tokenSecret),chr(38))) />
	</cfif>

	<cfset arguments.oAuthRequest.params['oauth_signature'] = local.signature />

	<cfreturn arguments.oAuthRequest />
</cffunction>


<cffunction name="toURL" returntype="string" access="public" output="false" hint="Serializes the oAuthRequest to a url">
	<cfargument name="oAuthRequest"		type="struct"	required="true"		hint="oAuthRequest to serialize" />
	<cfargument name="consumerSecret"	type="string"	required="false"	default=""	hint="Consumer secret used to sign" />
	<cfargument name="tokenSecret"		type="string"	required="false"	default=""	hint="Token secret used to sign" />

	<cfif NOT structKeyExists(arguments.oAuthRequest.params,'oauth_signature')>
		<cfset arguments.oAuthRequest = sign(oAuthRequest=duplicate(arguments.oAuthRequest),consumerSecret=arguments.consumerSecret,tokenSecret=arguments.tokenSecret) />
	</cfif>

	<cfreturn '#arguments.oAuthRequest.httpURL#?#toQueryString(arguments.oAuthRequest)#' />
</cffunction>


<cffunction name="toHeader" returntype="string" access="public" output="false" hint="Builds the authorization header">
	<cfargument name="oAuthRequest"	type="struct"	required="true"		hint="oAuthRequest to serialize" />
	<cfargument name="realm"				type="string"	required="false"	default=""	hint="Header realm if any" />

	<cfset local.header = '' />
	<cfif len(arguments.realm)>
		<cfset local.header = listAppend(local.header,'realm="#arguments.realm#"') />
	</cfif>

	<cfset local.oAuthRequest = sign(arguments.oAuthRequest) />
	<cfset structDelete(local.oAuthRequest,'oauth_token_secret') />

	<cfloop collection="#local.oAuthRequest.params#" item="local.key">
		<cfset local.header = listAppend(local.header,'#getOAuthUtilService().encode(local.key)#="#getOAuthUtilService().encode(local.oAuthRequest.params[local.key])#"') />
	</cfloop>

	<cfreturn 'OAuth #local.header#' />
</cffunction>


<cffunction name="toQueryString" returntype="string" access="public" output="false" hint="Converts a given oAuthRequest to a query string">
	<cfargument name="oAuthRequest"			type="struct"		required="true"		hint="oAuthRequest to serialize" />
	<cfargument name="excludeSignature"	type="boolean"	required="false"	default="false"	hint="If the signature should be excluded" />

	<cfset local.keys = '' />
	<cfloop collection="#arguments.oAuthRequest.params#" item="local.key">
		<cfset local.key = trim(local.key) />

		<cfif NOT listFindNoCase('oauth_signature,oauth_token_secret',local.key) OR NOT arguments.excludeSignature>
			<cfset local.keys = listAppend(local.keys,local.key) />
		</cfif>
	</cfloop>
	<cfset local.keys = listSort(local.keys,'text','asc') />

	<cfset local.queryString = '' />
	<cfloop list="#local.keys#" index="local.key">
		<cfset local.queryString = listAppend(local.queryString,'#getOAuthUtilService().encode(local.key)#=#getOAuthUtilService().encode(arguments.oAuthRequest.params[local.key])#',chr(38)) />
	</cfloop>

	<cfreturn local.queryString />
</cffunction>


<cffunction name="toSignableString" returntype="string" access="public" output="false" hint="Serializes a given oAuthRequest to a signable string">
	<cfargument name="oAuthRequest" type="struct" required="true" hint="oAuthRequest to serialize" />

	<cfset local.signableString	= getOAuthUtilService().encode(arguments.oAuthRequest.httpMethod) />
	<cfset local.signableString	= listAppend(local.signableString,getOAuthUtilService().encode(arguments.oAuthRequest.httpURL),chr(38)) />
	<cfset local.signableString = listAppend(local.signableString,getOAuthUtilService().encode(toQueryString(arguments.oAuthRequest,true)),chr(38)) />

	<cfreturn local.signableString />
</cffunction>


<cffunction name="ensureConsumer" returntype="any" access="public" output="false" hint="Ensure its a oAuthConsumerBean object">
	<cfargument name="consumer" type="any" required="true" hint="oAuthConsumerBean or oauth_consumer_key" />

	<cfif NOT isObject(arguments.consumer)>
		<cfset arguments.consumer = getOAuthConsumerService().loadByKey(arguments.consumer) />

		<cfif isNull(arguments.consumer)>
			<cfthrow type="OAuthException" message="Consumer invalid." />
		</cfif>
	</cfif>

	<cfreturn arguments.consumer />
</cffunction>


<cffunction name="ensureToken" returntype="any" access="public" output="false" hint="Ensures its a oAuthTokenBean object">
	<cfargument name="token" type="any" required="true" hint="oAuthTokenBean or oauth_token" />

	<cfif NOT isObject(arguments.token)>
		<cfset local.token = arguments.token />
		<cfset arguments.token = getOAuthTokenService().loadByKey(arguments.token) />

		<cfif isNull(arguments.token)>
			<cfthrow type="OAuthException" message="Token invalid." />
		</cfif>
	</cfif>

	<cfreturn arguments.token />
</cffunction>

</cfcomponent>