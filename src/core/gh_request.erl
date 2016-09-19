-module( gh_request ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).
-export( [get/2, get/3, delete/2, delete/3, post/3, post/4] ).

-define( ACCESS_TOKEN_KEY, 		"access_token" ).
-define( PAGE_KEY,				"page" ).
-define( EGITHUB_USER_AGENT,	{ "User-Agent", "egithub" } ).
-define( ACCEPT_JSON,			{ "Accept", "application/json" } ).

-type request() 		:: httpc:request().
-type param() 			:: { string(), string() }.
-type params() 			:: [param()].
-type method() 			:: get | post | delete.
-type content_type() 	:: string() | undefined.
-type response()		:: { error, term() } | { ok, jsx:json_term() } | { ok, tuple() } | { ok, atom() }.

-export_type( [response/0] ).

%%
%%	Perform an authenticated GET request against the specified API endpoint with the given query parameters.
%%
-spec get( [any()], list( { string(), string() } ), gh:state() ) -> response().
get( Endpoint, Params, Handle ) ->
	request( gh:base_url( Handle ), Endpoint, Params, get, undefined, undefined, gh:auth( Handle ) ).

-spec get( [any()], gh:state() ) -> response(); ( binary(), gh:state() ) -> response().
get( Url, Handle ) when is_binary( Url ) ->
	request( get, { want:string( Url ), auth( gh:auth( Handle ), [] ) }, want:string( Url ) );

get( Endpoint, Handle ) ->
	request( gh:base_url( Handle ), Endpoint, [], get, undefined, undefined, gh:auth( Handle ) ).
	
%%
%%	Perform an authenticated DELETE request against the specified API endpoint with the given query parameters.
%%
-spec delete( [string()], [ { string(), string() } ], gh:state() ) -> response().
delete( Endpoint, Params, Handle ) ->
	request( gh:base_url( Handle ), Endpoint, Params, delete, undefined, undefined, gh:auth( Handle ) ).

-spec delete( [string()], gh:state() ) -> { error, term() } | { ok, jsx:json_term() }.
delete( Endpoint, Handle ) ->
	request( gh:base_url( Handle ), Endpoint, [], delete, undefined, undefined, gh:auth( Handle ) ).

%%
%%	Perform a POST request to the specified API endpoint with the given query parameters and data.
%%
-spec post( [string()], [{ string(), string() }], term(), gh:state() ) -> response().
post( Endpoint, Params, Data, Handle ) ->
	request( gh:base_url( Handle ), Endpoint, Params, post, jsx:encode( Data ), "application/json", gh:auth( Handle ) ).
	
%%
%%	Perform an authenticated POST request to the specified API endpoint sending the given data.
%%
-spec post( [string()], term(), gh:state() ) -> response().
post( Endpoint, Data, Handle ) ->
    request( gh:base_url( Handle ), Endpoint, [], post, jsx:encode( Data ), "application/json", gh:auth( Handle ) ).

%%
%%	@doc Generate an authentication header for inclusion in a request based on the authentication method
%%	chosen during the gh:init phase
%%
-spec auth( atom() | { atom(), string() } | { atom(), string(), string() }, [{string(), string()}] ) -> [{ string(), string() }].
auth( anonymous, Headers ) -> 
	Headers;

auth( { oauth, Token }, Headers ) ->
	[{ "Authorization", string:concat( "token ", Token ) } | Headers];
	
auth( { basic, Username, Password }, Headers ) ->
	BasicAuth = base64:encode_to_string( lists:append( [ Username, ":", Password ] ) ),
    [{ "Authorization", string:concat( "Basic ", BasicAuth ) } | Headers].


%%
%%	@doc Generate a URL by joining a base URL with the provided path and query parameters
%%
-spec url( string() | binary(), [string()], [{ string(), string() }] ) -> string().
url( Url, Path, QueryParams ) when is_list( Url ) ->
	Transform = fun( U, P, Q ) -> binary_to_list( iolist_to_binary( lists:droplast( lists:flatten( [ U, 
							[ [ $/, Component ] || Component <- P ], 
							$?, 
		[ [ K, $=, V, $& ] || { K, V } <- Q ] ] ) ) ) ) end,
	case lists:last( Url ) of
		$/	-> 	Transform( lists:droplast( Url ), Path, QueryParams );
		_	->	Transform( Url, Path, QueryParams )
	end.	

%%
%%	Make a request to the github API
%%
-spec request( method(), request(), string(), [ term() ] ) -> { ok, term() } | { error, term() }.
request( Method, Request, Url, Data ) ->
	case httpc:request( Method, setelement( 1, Request, Url ), [], [{ body_format, binary }] ) of
		%% Request completed with no content returned
		{ ok, { { _Version, 204, _Reason }, _Headers, _Body } } ->
			{ ok, no_content };
		
		{ ok, { { _Version, Status, _Reason }, Headers, Body } } when Status >= 200 andalso Status < 300 ->
			JSONResponse = jsx:decode( Body, [ return_maps ] ),
			case gh_pagination:next_page( Headers ) of
				%% No pages left to retrieve
				undefined ->
					{ ok, lists:append( Data, JSONResponse ) };
				%% There are still pages left to retrieve
				NextUrl ->
					request( Method, Request, NextUrl, lists:append( Data, JSONResponse ) )
			end;			
		%% Some other status code
		{ ok, { { _Version, Status, Reason }, _Headers, Body } } ->
			{ error, { Status, Reason, Body } };
		%% Request failed
		{ error, Reason } -> 
			{ error, Reason }
	end.

-spec request( atom(), request(), string() ) -> { ok, term() } | { error, term() }.
request( Method, Request, Url ) ->
	request( Method, Request, Url, [] ).

-spec request( string(), [any()], params(), method(), term(), content_type(), gh:auth() ) -> { ok, term() } | { error, term() }.
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