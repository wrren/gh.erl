-module( gh ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [init/0, init/1, init/2, request_module/2] ).
-include_lib( "gh.hrl" ).

-type auth() 		:: atom() | { atom(), string() } | { atom(), string(), string() }.
-type state() 		:: #gh_state{}.
-type repository() 	:: gh_repo:repository().
-type branch() 		:: gh_branch:branch().
-type commit() 		:: gh_commit:commit().
-type commit_sha() 	:: gh_commit:sha().
-export_type( [state/0, auth/0, repository/0, branch/0, commit/0, commit_sha/0] ).

%%
%%  Initialize gh without an authentication token. Errors will occur if an attempt is made
%%  to access endpoints that require authentication.
%%
-spec init() -> #gh_state{}.
init() ->
	init( anonymous, ?GITHUB_API_URL ).

%%
%%  Initialize gh with the given authentication parameters
%%
-spec init( { atom(), string() } ) -> #gh_state{}.
init( Auth ) ->
	init( Auth, ?GITHUB_API_URL ).

%%
%%  Initialize gh with the given authentication parameters and API base URL
%%
-spec init( { atom(), string() }, string() ) -> #gh_state{}.
init( Auth =  anonymous, BaseUrl ) ->
	#gh_state{ base_url = BaseUrl, auth = Auth };

init( Auth =  { oauth, _Token }, BaseUrl ) ->
	#gh_state{ base_url = BaseUrl, auth = Auth };

init( Auth =  { basic, _Username, _Password }, BaseUrl ) ->
	#gh_state{ base_url = BaseUrl, auth = Auth }.
	
%%
%%	Override the request module used to communicate with the github API. Primarily used for
%%	testing purposes.
%%
-spec request_module( module(), #gh_state{} ) -> #gh_state{}.
request_module( Module, State = #gh_state{} ) ->
	State#gh_state{ request = Module }.