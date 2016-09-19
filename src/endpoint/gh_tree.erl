-module( gh_tree ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).
-export( [get/4, get/5] ).

-type tree() :: jsx:json_term().
-export_type( [tree/0] ).

-spec get( gh_repo:owner(), gh_repo:name(), gh_commit:sha(), gh:state() ) -> { ok, tree() } | { error, term() }.
get( Owner, Repo, SHA, State ) ->
    get( Owner, Repo, SHA, 0, State ).

-spec get( gh_repo:owner(), gh_repo:name(), gh_commit:sha(), non_neg_integer(), gh:state() ) -> { ok, tree() } | { error, term() }.
get( Owner, Repo, SHA, Recursive, State ) ->
    gh_request:get( ["repos", Owner, Repo, "git", "trees", SHA], [{ "recursive", want:string( Recursive ) }], State ).