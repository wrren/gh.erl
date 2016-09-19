-module( gh ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [init/0, init/1, init/2, auth/1, base_url/1] ).

-define( GITHUB_API_URL, "https://api.github.com" ).

%%
%%	State/configuration record
%%
-record( gh_state, { 	base_url	= ?GITHUB_API_URL	:: string(),
						auth 		= anonymous			:: gh:auth()
} ).

-type auth() 		:: atom() | { atom(), string() } | { atom(), string(), string() }.
-type state() 		:: #gh_state{}.
-type repository() 	:: gh_repo:repository().
-type branch() 		:: gh_branch:branch().
-type commit() 		:: gh_commit:commit().
-type commit_sha() 	:: gh_commit:sha().
-type hook()		:: gh_hook:hook().
-export_type( [state/0, auth/0, repository/0, branch/0, commit/0, commit_sha/0, hook/0] ).

%%
%%	@doc Get the auth method tuple from the gh state record
%%
-spec auth( state() ) -> auth().
auth( State )		-> State#gh_state.auth.

%%
%%	@doc Get the base URL from the gh state record
%%
-spec base_url( state() ) -> string().
base_url( State )	-> State#gh_state.base_url.

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

init( Auth =  { oauth, _Token }, BaseUrl ) when is_list( BaseUrl ) ->
	#gh_state{ base_url = BaseUrl, auth = Auth };

init( Auth =  { basic, _Username, _Password }, BaseUrl ) when is_list( BaseUrl ) ->
	#gh_state{ base_url = BaseUrl, auth = Auth }.
