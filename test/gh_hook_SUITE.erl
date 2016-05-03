-module( gh_hook_SUITE ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-define( TEST_HOOK_NAME, 	<<"web">> ).
-define( TEST_HOOK_URL,		<<"gh.me/hook">> ).
-define( TEST_HOOK_EVENTS,	[<<"push">>] ).

-compile( export_all ).

all() ->
	[{ group, create_and_delete }].
	
groups() -> [{ create_and_delete, [sequence], [create_test, delete_test] }].
	
init_per_suite( Config ) ->
	ok = application:start( inets ),
	ok = application:start( asn1 ),
	ok = application:start( crypto ),
	ok = application:start( public_key ),
	ok = application:start( ssl ),
	Config.
	
create_test( _Config ) ->
	Token 	= ct:get_config( gh_oauth_token ),
	Repo 	= ct:get_config( gh_repo ),
	Owner 	= ct:get_config( gh_user ),
	State 	= gh:init( { oauth, Token } ),
	
	{ ok, Hook }	= gh_hook:create( Owner, Repo, ?TEST_HOOK_NAME, ?TEST_HOOK_URL, <<"json">>, ?TEST_HOOK_EVENTS, true, State ),
	true = maps:is_key( ping_url, Hook ),
	
	{ ok, Hooks }	= gh_hook:list( Owner, Repo, State ),
	length( lists:filter( fun( #{ name := Name } ) -> binary_to_list( Name ) == ?TEST_HOOK_NAME end, Hooks ) ) == 1.
		
delete_test( _Config ) ->
	Token 	= ct:get_config( gh_oauth_token ),
	Repo 	= ct:get_config( gh_repo ),
	Owner 	= ct:get_config( gh_user ),
	State 	= gh:init( { oauth, Token } ),
	
	ok = gh_hook:delete( Owner, Repo, ?TEST_HOOK_NAME, State ),
	{ ok, Hooks }	= gh_hook:list( Owner, Repo, State ),
	length( lists:filter( fun( #{ name := Name } ) -> binary_to_list( Name ) == ?TEST_HOOK_NAME end, Hooks ) ) == 0.
		
end_per_suite( Config ) ->
	application:stop( ssl ),
	application:stop( public_key ),
	application:stop( crypto ),
	application:stop( asn1 ),
	application:stop( inets ),
	Config.
	