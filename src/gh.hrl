%%
%%	State/configuration record
%%
-record( gh_state, { 	base_url	:: string(),
						auth 		:: { atom(), string() } | { atom(), string(), string() }
} ).