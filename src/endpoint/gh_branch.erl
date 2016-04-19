-module( gh_branch ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

%% Query Functions
-export( [list/2] ).
%% Accessors
-export( [name/1, commit_sha/1, commit_url/1] ).

%% Type Exports
-type branch() :: map().
-export_type( [branch/0] ).

%%
%%	List all branches under the given repository
%%
-spec list( gh_repo:repository(), gh:state() ) -> { ok, [ branch() ] } | { error, term() }.
list( Repository, State ) ->
	gh_request:get( ["repos", gh_repo:owner( Repository ), gh_repo:name( Repository ), "branches" ], State ).
	
%% Get the branch name
name( #{ name := Name } )						-> Name.
%% Get the latest commit SHA1
commit_sha( #{ commit := #{ sha := Sha } } )	-> Sha.
%% Get a link to detailes on the latest commit
commit_url( #{ commit := #{ url := Url } } )	-> Url.