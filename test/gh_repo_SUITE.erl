-module( gh_repo_SUITE ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-compile( export_all ).
-include_lib("ct.hrl").

all() ->
	[{ group, list_and_detail }].
	
groups() -> [{ list_and_detail, [sequence], [repo_list_test, repo_name_test] }].
	
init_per_suite( Config ) ->
	ok = application:start( inets ),
	ok = application:start( asn1 ),
	ok = application:start( crypto ),
	ok = application:start( public_key ),
	ok = application:start( ssl ),
	Token = ct:get_config( gh_oauth_token ),
	State = gh:init( { oauth, Token } ),
	[ { gh_state, State } | Config ].
	
repo_list_test( Config ) ->
	State = ?config( gh_state, Config ),
	
	{ ok, RepositoryList } = gh_repo:list( State, [{ affiliation, [ "owner" ] } ] ),
	
	{ ok, [ Repository | _ ] } 	= gh_repo:list( State ),
	true = maps:is_key( name, Repository ),
	NewConfig	= [{ repository, Repository } | Config ],
	{ save_config, NewConfig }.
		
repo_name_test( Config ) ->
	State 							= ?config( gh_state, Config ),
	{ repo_list_test, NewConfig }	= ?config( saved_config, Config ),
	Repo 							= ?config( repository, NewConfig ),
	
	Owner 			= gh_repo:owner( Repo ),
	Name 			= gh_repo:name( Repo ),
	{ ok, JSON }	= gh_repo:by_name( Owner, Name, State ),
	Admin 			= gh_repo:admin( Repo ),
	Name 			= gh_repo:name( JSON ).	
		
end_per_suite( Config ) ->
	application:stop( ssl ),
	application:stop( public_key ),
	application:stop( crypto ),
	application:stop( asn1 ),
	application:stop( inets ),
	Config.
	