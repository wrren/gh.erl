-module( gh_branch_SUITE ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-compile( export_all ).

all() ->
	[ branch_list_test ].
	
init_per_suite( Config ) ->
	application:start( inets ),
	application:start( asn1 ),
	application:start( crypto ),
	application:start( public_key ),
	application:start( ssl ),
	Config.
	
branch_list_test( _Config ) ->
	Token = ct:get_config( gh_oauth_token ),
	State = gh:init( { oauth, Token } ),
	{ ok, [ Repository | _ ] } 	= gh_repo:list( State ),
	{ ok, [ Branch | _ ] }	 	= gh_branch:list( Repository, State ),
	true = maps:is_key( name, Branch ).
		
end_per_suite( Config ) ->
	application:stop( ssl ),
	application:stop( public_key ),
	application:stop( crypto ),
	application:stop( asn1 ),
	application:stop( inets ),
	Config.
	