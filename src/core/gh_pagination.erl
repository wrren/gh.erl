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
%% Characters surrounding the URL
-define( URL_BOUNDARY_CHARS, 	"<>" ).
%% Character surrounding the rel element
-define( REL_BOUNDARY_CHAR, 	"\"" ).

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
%%	Extract the Link header and produce a proplist of provided links
%%
-spec links( headers(), [link()] ) -> [link()]
links( [H | T], Out ) ->
	case string:tokens( H, ?URL_REL_SEPARATOR ) of
		[ UrlEncoded, RelEncoded ] 	-> 
			[ Url ]		= string:tokens( UrlEncoded, ?URL_BOUNDARY_CHARS ),
			[ _, Rel ]	= string:tokens( RelEncoded, ?REL_BOUNDARY_CHAR ),
			links( T, rel( Rel, Url, Out ) );
		
		_ 							-> links( T, Out )
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
		{ last, Url }	-> Url;
		_ 				-> undefined
	end.