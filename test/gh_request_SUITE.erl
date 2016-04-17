-module( gh_request_SUITE ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-compile( export_all ).

all() ->
	[ feed_request ].
	
init_per_suite( Config ) ->
	ok = application:start( inets ),
	ok = application:start( asn1 ),
	ok = application:start( crypto ),
	ok = application:start( public_key ),
	ok = application:start( ssl ),
	Config.
	
feed_request( _Config ) ->
	User = ct:get_config( gh_user ),
	State = gh:init(),
	{ ok, _JSON } = gh_request:get( [ "feeds" ], State ).
	
end_per_suite( Config ) ->
	application:stop( ssl ),
	application:stop( public_key ),
	application:stop( crypto ),
	application:stop( asn1 ),
	application:stop( inets ),
	Config.
	