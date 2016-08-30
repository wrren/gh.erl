-module( gh_request ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [get/3, get/2, delete/2, delete/3, post/3, post/4] ).

-include_lib( "gh/include/gh.hrl" ).

%%
%%	Types into which JSON may be decoded
%%
-type json() :: [map()] | map().

-export_type( [json/0] ).

%%
%%	Perform an authenticated GET request against the specified API endpoint with the given query parameters.
%%
-spec get( [string()], [ { string(), string() } ], #gh_state{} ) -> { error, term() } | { ok, map() }.
get( Endpoint, Params, #gh_state{ base_url = BaseUrl, auth = Auth, request = Module } ) ->
	Module:request( BaseUrl, Endpoint, Params, get, undefined, undefined, Auth ).

-spec get( [string()], #gh_state{} ) -> { error, term() } | { ok, map() }.
get( Endpoint, #gh_state{ base_url = BaseUrl, auth = Auth, request = Module } ) ->
	Module:request( BaseUrl, Endpoint, [], get, undefined, undefined, Auth ).
	
%%
%%	Perform an authenticated DELETE request against the specified API endpoint with the given query parameters.
%%
-spec delete( [string()], [ { string(), string() } ], #gh_state{} ) -> { error, term() } | { ok, map() }.
delete( Endpoint, Params, #gh_state{ base_url = BaseUrl, auth = Auth, request = Module } ) ->
	Module:request( BaseUrl, Endpoint, Params, delete, undefined, undefined, Auth ).

-spec delete( [string()], #gh_state{} ) -> { error, term() } | { ok, map() }.
delete( Endpoint, #gh_state{ base_url = BaseUrl, auth = Auth, request = Module } ) ->
	Module:request( BaseUrl, Endpoint, [], delete, undefined, undefined, Auth ).

%%
%%	Perform a POST request to the specified API endpoint with the given query parameters and data.
%%
-spec post( [string()], [{ string(), string() }], term(), #gh_state{} ) -> { error, term() } | { ok, map() }.
post( Endpoint, Params, Data, #gh_state{ base_url = BaseUrl, auth = Auth, request = Module } ) ->
	Module:request( BaseUrl, Endpoint, Params, post, jsx:encode( Data ), "application/json", Auth ).
	
%%
%%	Perform an authenticated POST request to the specified API endpoint sending the given data.
%%
-spec post( [string()], term(), #gh_state{} ) -> { error, term() } | { ok, map() }.
post( Endpoint, Data, #gh_state{ base_url = BaseUrl, auth = Auth, request = Module } ) ->
	Module:request( BaseUrl, Endpoint, [], post, jsx:encode( Data ), "application/json", Auth ).