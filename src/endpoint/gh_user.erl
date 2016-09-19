-module( gh_user ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [get/1] ).

-type user() :: jsx:json_term().

-export_type( [user/0] ).

%%
%%	Get the currently authenticated user's details
%%
-spec get( gh:state() ) -> { ok, user() } | { error, term() }.
get( State ) ->
	gh_request:get( ["user"], State ).