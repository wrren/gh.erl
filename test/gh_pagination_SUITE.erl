-module( gh_pagination_SUITE ).
-include_lib( "common_test/include/ct.hrl" ).
-export( [all/0] ).
-export( [next_link/1, page_count/1] ).
 
all() -> [test1,test2].
 
test1(_Config) ->
1 = 1.
 
test2(_Config) ->
A = 0,
1/A.