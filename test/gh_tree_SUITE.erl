-module( gh_tree_SUITE ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-compile( export_all ).

all() ->
	[ tree_request ].
	
init_per_suite( Config ) ->
	application:start( inets ),
	application:start( asn1 ),
	application:start( crypto ),
	application:start( public_key ),
	application:start( ssl ),
	Config.
	
tree_request( _Config ) ->
	Token = ct:get_config( gh_oauth_token ),
	State = gh:init( { oauth, Token } ),
	{ ok, Tree } 	= gh_tree:get( ct:get_config( gh_user ), ct:get_config( gh_repo ), ct:get_config( gh_sha ), State ),
	true = maps:is_key( <<"sha">>, Tree ),
    true = maps:is_key( <<"tree">>, Tree ).
	
end_per_suite( Config ) ->
	application:stop( ssl ),
	application:stop( public_key ),
	application:stop( crypto ),
	application:stop( asn1 ),
	application:stop( inets ),
	Config.
	