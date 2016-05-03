-module( gh_want ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [binary/1, string/1, boolean/1] ).

%%
%%	Convert the given value to a binary
%%
binary( Val ) when is_binary( Val ) 	-> Val;
binary( Val ) when is_float( Val )		-> float_to_binary( Val );
binary( Val ) when is_integer( Val )	-> integer_to_binary( Val );
binary( Val ) when is_list( Val )		-> list_to_binary( Val );
binary( Val )							-> term_to_binary( Val ).

%%
%%	Convert the given value to a string
%%
string( true )							-> "true";
string( false )							-> "false";
string( Val ) when is_integer( Val )	-> integer_to_list( Val );
string( Val ) when is_float( Val ) 		-> float_to_list( Val ); 
string( Val ) when is_binary( Val )		-> binary_to_list( Val );
string( Val ) when is_list( Val )		-> Val.

%%
%%	Convert the given value to a boolean
%%
boolean( true )							-> true;
boolean( false )						-> false;
boolean( <<"true">> )					-> true;
boolean( <<"false">> )					-> false;
boolean( "true" )						-> true;
boolean( "false" )						-> false.