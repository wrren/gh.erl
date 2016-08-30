-module( gh_request_SUITE ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-compile( export_all ).

all() ->
	[ feed_request ].
	
init_per_suite( Config ) ->
	application:start( inets ),
	application:start( asn1 ),
	application:start( crypto ),
	application:start( public_key ),
	application:start( ssl ),
	Config.
	
feed_request( _Config ) ->
	State = gh:init(),
	{ ok, _JSON } = gh_request:get( [ "feeds" ], State ).
	
end_per_suite( Config ) ->
	application:stop( ssl ),
	application:stop( public_key ),
	application:stop( crypto ),
	application:stop( asn1 ),
	application:stop( inets ),
	Config.
	