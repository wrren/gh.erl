-module( gh_httpc_request ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [request/7] ).

-define( ACCESS_TOKEN_KEY, 		"access_token" ).
-define( PAGE_KEY,				"page" ).
-define( EGITHUB_USER_AGENT,	{ "User-Agent", "egithub" } ).
-define( ACCEPT_JSON,			{ "Accept", "application/json" } ).

-type request() :: httpc:request().
-type param() 	:: { string(), string() }.
-type params()	:: [param()].

%%
%%	Generate an authentication header for inclusion in a request based on the authentication method
%%	chosen during the gh:init phase
%%
-spec auth( atom() | { atom(), string() } | { atom(), string(), string() }, [{string(), string()}] ) -> { string(), string() }.
auth( anonymous, Headers ) -> 
	Headers;

auth( { oauth, Token }, Headers ) ->
	[{ "Authorization", string:concat( "token ", Token ) } | Headers];
	
auth( { basic, Username, Password }, Headers ) ->
	BasicAuth = base64:encode_to_string( lists:append( [ binary_to_list( Username ), ":", binary_to_list( Password ) ] ) ),
	[{ "Authorization", string:concat( "Basic ", BasicAuth ) } | Headers].

%%
%%	Generate a URL by joining a base URL with the provided path and query parameters
%%
-spec url( binary() | list(), binary() | list(), [{ list() | binary(), list() | binary() }] ) -> binary().
url( Url, Path, QueryParams ) when is_list( Url ) ->
	case lists:last( Url ) of
		$/	-> 	url( lists:droplast( Url ), Path, QueryParams );
		_	->	url( list_to_binary( Url ), Path, QueryParams )
	end;

url( <<Url, $/>>, Path, QueryParams ) ->
	url( Url, Path, QueryParams );

url( Url, Path, QueryParams ) ->
	binary_to_list( iolist_to_binary( lists:droplast( lists:flatten( [ 	Url, 
							[ [ $/, P ] || P <- Path ], 
							$?, 
							[ [ K, $=, V, $& ] || { K, V } <- QueryParams ] ] ) ) ) ).

%%
%%	Make a request to the github API
%%
-spec request( atom(), request(), string(), [ term() ] ) -> { ok, term() } | { error, term() }.
request( Method, Request, Url, Data ) ->
	case httpc:request( Method, setelement( 1, Request, Url ), [], [{ body_format, binary }] ) of
		{ ok, { { _Version, 200, _Reason}, Headers, Body } } ->
			JSONResponse = jsx:decode( Body, [ { labels, atom }, return_maps ] ),
			case gh_pagination:next_page( Headers ) of
				%% No pages left to retrieve
				undefined ->
					{ ok, lists:append( Data, JSONResponse ) };
				%% There are still pages left to retrieve
				NextUrl ->
					request( Method, Request, NextUrl, lists:append( Data, JSONResponse ) )
			end;			
		%% Some other status code
		{ ok, { { _Version, _, Reason }, _Headers, _Body } } ->
			{ error, Reason };
		%% Request failed
		{ error, Reason } -> 
			{ error, Reason }
	end.

-spec request( atom(), request(), string() ) -> { ok, term() } | { error, term() }.
request( Method, Request, Url ) ->
	request( Method, Request, Url, [] ).

-spec request( string(), [string()], params(), atom(), term(), string(), gh:auth() ) -> { ok, term() } | { error, term() }.
request( BaseUrl, Endpoint, Params, Method, Body, ContentType, Auth ) when 		Method =:= post 	orelse 
																				Method =:= put 		orelse 
																				Method =:= patch ->
	Url = url( BaseUrl, Endpoint, Params ),
	request( Method, { Url, auth( Auth, [?ACCEPT_JSON, ?EGITHUB_USER_AGENT] ), ContentType, Body }, Url );

request( BaseUrl, Endpoint, Params, Method, _Body, _ContentType, Auth ) when 	Method =:= get 		orelse 
																				Method =:= delete 	orelse 
																				Method =:= head 	orelse 
																				Method =:= options ->
	Url = url( BaseUrl, Endpoint, Params ),
	request( Method, { Url, auth( Auth, [?ACCEPT_JSON, ?EGITHUB_USER_AGENT] ) }, Url ).
