-module( gh_branch ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

%% Query Functions
-export( [list/2, list/3, make/3] ).
%% Accessors
-export( [name/1, commit_sha/1, commit_url/1] ).

%% Type Exports
-type branch() :: map().
-export_type( [branch/0] ).

%%
%%	@doc List all branches under the given repository
%%
-spec list( gh_repo:repository(), gh:state() ) -> { ok, [ branch() ] } | { error, term() }.
list( Repository, State ) ->
	list( gh_repo:owner( Repository ), gh_repo:name( Repository ), State ).

%%
%%	@doc List all branches under the given repository
%%	
-spec list( gh_repo:owner(), gh_repo:name(), gh:state() ) -> { ok, [ branch() ] } | { error, term() }.
list( Owner, Repository, State ) ->
	gh_request:get( ["repos", Owner, Repository, "branches" ], State ).

%% Get the branch name
name( #{ name := Name } )						-> Name.
%% Get the latest commit SHA1
commit_sha( #{ commit := #{ sha := Sha } } )	-> Sha.
%% Get a link to detailes on the latest commit
commit_url( #{ commit := #{ url := Url } } )	-> Url.

%%
%%  Generate a map with a format matching that of a decoded branch JSON blob, useful for testing
%%  without knowledge of map internals.
%%
-spec make( binary(), binary(), binary() ) -> branch().
make( Name, CommitSHA, CommitURL ) ->
    #{  name 		=> Name,
		commit 		=> #{ sha => CommitSHA, url => CommitURL } }.