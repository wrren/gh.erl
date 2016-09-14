-module( gh_tree ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).
-export( [get/4, get/5] ).

get( Owner, Repo, SHA, State ) ->
    get( Owner, Repo, SHA, 0, State ).

get( Owner, Repo, SHA, Recursive, State ) ->
    gh_request:get( ["repos", Owner, Repo, "git", "trees", SHA], [{ "recursive", want:string( Recursive ) }], State ).