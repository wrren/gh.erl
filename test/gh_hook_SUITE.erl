-module( gh_hook_SUITE ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-include_lib( "common_test/include/ct.hrl" ).

-define( TEST_HOOK_URL,		<<"gh.me/hook">> ).
-define( TEST_HOOK_EVENTS,	[<<"push">>] ).

-compile( export_all ).

all() ->
	[{ group, create_and_delete }].
	
groups() -> [{ create_and_delete, [sequence], [create_test, delete_test] }].
	
init_per_suite( Config ) ->
	application:start( inets ),
	application:start( asn1 ),
	application:start( crypto ),
	application:start( public_key ),
	application:start( ssl ),
	Config.
	
create_test( _Config ) ->
	Token 	= ct:get_config( gh_oauth_token ),
	Repo 	= ct:get_config( gh_repo ),
	Owner 	= ct:get_config( gh_user ),
	State 	= gh:init( { oauth, Token } ),
	
	{ ok, Hook }	= gh_hook:create_web( Owner, Repo, ?TEST_HOOK_URL, <<"json">>, ?TEST_HOOK_EVENTS, <<"SecretKey">>, true, State ),
	true = maps:is_key( <<"ping_url">>, Hook ),
	
	{ ok, Hooks }	= gh_hook:list( Owner, Repo, State ),
	1 = length( lists:filter( fun( H ) -> gh_hook:config_url( H ) == ?TEST_HOOK_URL end, Hooks ) ),
	{ save_config, [{ hook_id, gh_hook:id( Hook ) }] }.
		
delete_test( Config ) ->
	{ create_test, HookConfig }	= ?config( saved_config, Config ),
	ID 							= ?config( hook_id, HookConfig ),
	
	Token 	= ct:get_config( gh_oauth_token ),
	Repo 	= ct:get_config( gh_repo ),
	Owner 	= ct:get_config( gh_user ),
	State 	= gh:init( { oauth, Token } ),
	
	ok 				= gh_hook:delete( Owner, Repo, ID, State ),
	{ error, _ }	= gh_hook:by_id( Owner, Repo, ID, State ).
		
end_per_suite( Config ) ->
	application:stop( ssl ),
	application:stop( public_key ),
	application:stop( crypto ),
	application:stop( asn1 ),
	application:stop( inets ),
	Config.
	