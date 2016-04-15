-module( gh ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [init/1, init/2] ).
-include_lib( "gh.hrl" ).

-define( GITHUB_API_URL, "https://api.github.com" ).

%%
%%  Initialize gh with the given authentication parameters
%%
-spec init( { atom(), string() } ) -> #gh_state{}.
init( Auth ) ->
    init( Auth, ?GITHUB_API_URL ).

%%
%%  Initialize gh with the given authentication parameters and API base URL
%%
-spec init( { atom(), string() }, string() ) -> #gh_state{}.
init( Auth =  { oauth, _Token }, BaseUrl ) ->
    #gh_state{ base_url = BaseUrl, auth = Auth };

init( Auth =  { basic, _Username, _Password }, BaseUrl ) ->
    #gh_state{ base_url = BaseUrl, auth = Auth }.