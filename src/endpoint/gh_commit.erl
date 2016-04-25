-module( gh_commit ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

%% Query Functions
-export( [list/2, by_sha/3, sha/1] ).

%% Type Exports
-type commit() 		:: map().
-type sha()			:: string().
-export_type( [commit/0, sha/0] ).

%%
%%	List all commits made on the specified repository
%%
-spec list( gh_repo:repository(), gh:state() ) -> { ok, [commit()] } | { error, term() }.
list( Repository, State ) ->
	gh_request:get( ["repos", gh_repo:owner( Repository ), gh_repo:name( Repository ), "commits" ], State ).
	
%%
%%	Get details on a single commit identified by its SHA1 signature
%%
-spec by_sha( gh_repo:repository(), sha(), gh:state() ) -> { ok, commit() } | { error, term() }.
by_sha( Repository, Sha, State ) ->
	gh_request:get( ["repos", gh_repo:owner( Repository ), gh_repo:name( Repository ), "commits", Sha ], State ).
	
%%
%%	Get the SHA1 hash of this commit
%%
sha( #{ sha := Sha } ) -> Sha.