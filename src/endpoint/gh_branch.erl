-module( gh_branch ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

%% Query Functions
-export( [get/4, list/2, list/3, commits/4, make/3] ).
%% Accessors
-export( [name/1, commit_sha/1, commit_url/1] ).

%% Type Exports
-type branch() 	:: jsx:json_term().
-type name() 	:: binary().
-export_type( [branch/0, name/0] ).

%%
%%	@doc Get a single branch by name from the given repository
%%
-spec get( gh_repo:owner(), gh_repo:name(), gh_branch:name(), gh:state() ) -> { error, term() } | { ok, branch() }.
get( Owner, Repository, Branch, State ) ->
	gh_request:get( ["repos", Owner, Repository, "branches", Branch ], State ).

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

%%
%%	@doc Get a list of all commits made under the given branch
%%
-spec commits( gh_repo:owner(), gh_repo:name(), name(), gh:state() ) -> { ok, [gh:commit()] } | { error, term() }.
commits( Owner, Repository, Branch, State ) ->
	gh_request:get( ["repos", Owner, Repository, "commits" ], [{ "sha", Branch }], State ).

%% Get the branch name
name( #{ <<"name">>:= Name } )						-> Name.
%% Get the latest commit SHA1
commit_sha( #{ <<"commit">> := #{ <<"sha">>:= Sha } } )	-> Sha.
%% Get a link to detailes on the latest commit
commit_url( #{ <<"commit">> := #{ <<"url">> := Url } } )	-> Url.

%%
%%  Generate a map with a format matching that of a decoded branch JSON blob, useful for testing
%%  without knowledge of map internals.
%%
-spec make( binary(), binary(), binary() ) -> branch().
make( Name, CommitSHA, CommitURL ) ->
    #{  <<"name">> 		=> Name,
		<<"commit">> 	=> #{ <<"sha">> => CommitSHA, <<"url">> => CommitURL } }.