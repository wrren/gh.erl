-module( gh_pagination ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

%%
%%	This module contains functions for parsing pagination headers from Github API responses
%%
-export( [next_page/1, page_count/1] ).
	
%%	Separates individual links in the header content
-define( LINK_SEPARATOR,	"," ).
%% Separates the URL from the link type in a single link
-define( URL_REL_SEPARATOR, ";" ).
%% URL Component Regex
-define( URL_CAPTURE_REGEX, "<(.+)>" ).
%% Rel Component Regex
-define( REL_CAPTURE_REGEX, "rel=\"([a-z]+)\"" ).
%% For query parameters, the character separating key-value pairs from eachother
-define( PARAM_SEPARATOR, 		"&" ).
%% For single query parameters, the character separating keys from values
-define( KEY_VALUE_SEPARATOR,	"=" ).
%% Page number query parameter key
-define( PAGE_KEY,				"page" ).

%%	Link descriptor/url pair
-type link() 		:: { atom(), string() }.
%%	Single header pair
-type header() 		:: { string(), string() }.
%% 	List of headers
-type headers() 	:: [header()].

%%
%%	Extract and encode the rel link type and add it to the output array. If the rel type isn't
%%	recognized, the output array will not have anything added to it.
%%
-spec rel( string(), string(), [link()] ) -> [link()].
rel( "prev", Url, Out )		-> [{ prev, Url } | Out];
rel( "next", Url, Out ) 	-> [{ next, Url } | Out];
rel( "last", Url, Out ) 	-> [{ last, Url } | Out];
rel( "first", Url, Out )	-> [{ first, Url } | Out];
rel( _, _, Out )			-> Out.

%%
%%	Given a URL that points to one page in a paginated result set, parse the page number from the URL
%%
-spec page_number( string() ) -> undefined | pos_integer().
page_number( [ [ ?PAGE_KEY, Value ] | _T ] ) ->
	case string:to_integer( Value ) of
		{ error, _Reason }		-> undefined;
		{ PageNumber, _Rest }	-> PageNumber
	end;

page_number( [ Tokens | T ] ) when is_list( Tokens ) ->
	page_number( T );
	
page_number( [] ) -> undefined;

page_number( Url ) ->
	page_number( [ string:tokens( X, ?KEY_VALUE_SEPARATOR ) || X <- string:tokens( Url, ?PARAM_SEPARATOR ) ] ).

%%
%%	Extract the Link header and produce a proplist of provided links
%%
-spec links( headers(), [link()] ) -> [link()].
links( [H | T], Out ) ->
	case { 	re:run( H, ?URL_CAPTURE_REGEX, [{ capture, all_but_first, list}] ),
			re:run( H, ?REL_CAPTURE_REGEX, [{ capture, all_but_first, list}] ) } of
		{ { match, [ Url ] }, { match, [ Rel ] } }	-> links( T, rel( Rel, Url, Out ) );
		_ 											-> links( T, Out )
	end;
	
links( [], Out ) -> Out.

-spec links( headers() ) -> [link()].
links( Headers ) ->
	case lists:keyfind( "Link", 1, Headers ) of
		{ "Link", Content }	-> links( string:tokens( Content, ?LINK_SEPARATOR ), [] );
		_					-> []
	end.

%%
%%	Parse and return the Url of the next page as described by the given headers. If no next page Url is present,
%%	the atom 'undefined' is returned instead
%%
-spec next_page( headers() ) -> string() | undefined.
next_page( Headers ) ->
	case lists:keyfind( next, 1, links( Headers ) ) of
		{ next, Url }	-> Url;
		_ 				-> undefined
	end.

%%
%%	Determine the number of pages in the overall Github API response.
%%
-spec page_count( headers() ) -> pos_integer() | undefined.
page_count( Headers ) ->
	case lists:keyfind( last, 1, links( Headers ) ) of
		{ last, Url }	-> page_number( Url );
		_ 				-> undefined
	end.