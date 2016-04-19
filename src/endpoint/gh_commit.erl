-module( gh_commit ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

%% Query Functions
-export( [list/2, by_signature/3] ).

%% Type Exports
-type commit() 		:: map().
-type signature()	:: string().
-export_type( [commit/0, signature/0] ).

%%
%%	List all commits made on the specified repository
%%
-spec list( gh_repo:repository(), gh:state() ) -> { ok, [commit()] } | { error, term() }.
list( Repository, State ) ->
	gh_request:get( ["repos", gh_repo:owner( Repository ), gh_repo:name( Repository ), "commits" ], State ).
	
%%
%%	Get details on a single commit identified by its SHA1 signature
%%
-spec by_signature( gh_repo:repository(), signature(), gh:state() ) -> { ok, commit() } | { error, term() }.
by_signature( Repository, Signature, State ) ->
	gh_request:get( ["repos", gh_repo:owner( Repository ), gh_repo:name( Repository ), "commits", Signature ], State ).