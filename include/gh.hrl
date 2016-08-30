-define( GITHUB_API_URL, "https://api.github.com" ).

%%
%%	State/configuration record
%%
-record( gh_state, { 	base_url	= ?GITHUB_API_URL	:: string(),
						auth 		= anonymous			:: gh:auth(),
						request		= gh_httpc_request 	:: module()
} ).