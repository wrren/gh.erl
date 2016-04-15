-module( gh_request ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [get/3, get/2] ).

-include_lib( "gh.hrl" ).

-define( ACCESS_TOKEN_KEY, 		"access_token" ).
-define( PAGE_KEY,				"page" ).
-define( EGITHUB_USER_AGENT,	{ "User-Agent", "egithub" } ).
-define( ACCEPT_JSON,			{ "Accept", "application/json" } ).

-type request() :: httpc:request().

%%
%%	Generate an authentication header for inclusion in a request based on the authentication method
%%	chosen during the gh:init phase
%%
-spec auth( { atom(), string() } | { atom(), string(), string() } ) -> { string(), string() }.
auth( { oauth, Token } ) ->
	{ "Authorization", string:concat( "token ", Token ) };
	
auth( { basic, Username, Password } ) ->
	BasicAuth = base64:encode_to_string( lists:append( [ binary_to_list( Username ), ":", binary_to_list( Password ) ] ) ),
	{ "Authorization", string:concat( "Basic ", BasicAuth ) }.

%%
%%	Generate a URL by joining a base URL with the provided path and query parameters
%%
-spec url( binary() | list(), binary() | list() ) -> binary().
url( Url, Path ) ->
	url( Url, Path, [] ).

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
					{ ok, [ JSONResponse | Data ] };
				%% There are still pages left to retrieve
				NextUrl ->
					request( Method, Request, NextUrl, [ JSONResponse | Data ] )
			end;			
		%% Some other status code
		{ ok, { { _Version, _, Reason }, _Headers, _Body } } ->
			{ error, Reason, Url };
		%% Request failed
		{ error, Reason } -> 
			{ error, Reason, Url }
	end.

request( Method, Request, Url ) ->
	request( Method, Request, Url, [] ).

request( BaseUrl, Endpoint, Params, Method, Body, ContentType, Auth ) when Method =:= post orelse Method =:= put ->
	Url = url( BaseUrl, [ Endpoint ], Params ),
	request( Method, { Url, [?ACCEPT_JSON, ?EGITHUB_USER_AGENT, auth( Auth )], ContentType, Body }, Url ).

request( BaseUrl, Endpoint, Params, get, Auth ) ->
	Url = url( BaseUrl, [ Endpoint ], Params ),
	request( get, { Url, [?ACCEPT_JSON, ?EGITHUB_USER_AGENT, auth( Auth )] }, Url ).

%%
%%	Perform an authenticated GET request against the specified API endpoint with the given query parameters.
%%
-spec get( string(), [ { string(), string() } ], #gh_state{} ) -> { error, term() } | { ok, map() }.
get( Endpoint, Params, #gh_state{ base_url = BaseUrl, auth = Auth } ) ->
	request( BaseUrl, Endpoint, Params, get, Auth ).

-spec get( string(), #gh_state{} ) -> { error, term() } | { ok, map() }.
get( Endpoint, #gh_state{ base_url = BaseUrl, auth = Auth } ) ->
	request( BaseUrl, Endpoint, [], get, Auth ).