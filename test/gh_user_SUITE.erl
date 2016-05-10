-module( gh_user_SUITE ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-compile( export_all ).
-include_lib("ct.hrl").

all() -> [ get ].

init_per_suite( Config ) ->
	ok = application:start( inets ),
	ok = application:start( asn1 ),
	ok = application:start( crypto ),
	ok = application:start( public_key ),
	ok = application:start( ssl ),
	Token = ct:get_config( gh_oauth_token ),
	State = gh:init( { oauth, Token } ),
	[ { gh_state, State } | Config ].
	
get( Config ) ->
	State = ?config( gh_state, Config ),
	{ ok, User } = gh_user:get( State ).
		
end_per_suite( Config ) ->
	application:stop( ssl ),
	application:stop( public_key ),
	application:stop( crypto ),
	application:stop( asn1 ),
	application:stop( inets ),
	Config.
	