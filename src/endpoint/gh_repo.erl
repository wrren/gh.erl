-module( gh_repo ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [list/1] ).

list( State ) ->
    case gh_request:get( "user/repos", State ) of
        { ok, JSON }             ->  { ok, JSON };
        { error, Reason, Url }   ->  { error, Reason, Url }
    end.