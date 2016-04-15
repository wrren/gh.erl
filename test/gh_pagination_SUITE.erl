-module( gh_pagination_SUITE ).
-include_lib( "common_test/include/ct.hrl" ).
-export( [all/0] ).
-export( [next_page/1, page_count/1] ).
 
-define( LINK_SAMPLE_1, [ { "Link", "   <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=2>; rel=\"next\", 
                                        <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=34>; rel=\"last\"" } ] ).
                                        
-define( LINK_SAMPLE_2, [ { "Link", "   <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=15>; rel=\"next\", 
                                        <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=35>; rel=\"last\",
                                        <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=1>; rel=\"first\",
                                        <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=13>; rel=\"prev\"" } ] ).
                                        
-define( LINK_SAMPLE_3, [] ).
 
all() -> [next_page, page_count].
 
next_page( _Config ) ->
    "https://api.github.com/search/code?q=addClass+user%3Amozilla&page=2"   = gh_pagination:next_page( ?LINK_SAMPLE_1 ),
    "https://api.github.com/search/code?q=addClass+user%3Amozilla&page=15"  = gh_pagination:next_page( ?LINK_SAMPLE_2 ),
    undefined                                                               = gh_pagination:next_page( ?LINK_SAMPLE_3 ).

page_count( _Config ) ->
    34              = gh_pagination:page_count( ?LINK_SAMPLE_1 ),
    35              = gh_pagination:page_count( ?LINK_SAMPLE_2 ),
    undefined       = gh_pagination:page_count( ?LINK_SAMPLE_3 ).