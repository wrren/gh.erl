-module( gh_hook ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-define( WEB_HOOK_NAME, <<"web">> ).

%% Queries
-export( [	make/5,
			list/2, list/3, 
			by_id/3, by_id/4, 
			by_name/3, by_name/4,
			by_url/3, by_url/4,
			create_web/6, create_web/7, 
			create/7, create/8, 
			delete/3, delete/4] ).
%% Accessors
-export( [ 	id/1, url/1, config_url/1, content_type/1, test_url/1, ping_url/1, name/1, events/1, active/1, config/1, 
			updated_at/1, created_at/1] ).

-type id() 		:: binary() | pos_integer().
-type event() 	:: binary().
-type name() 	:: binary().
-type hook() 	:: map().
-export_type( [id/0, hook/0, name/0, event/0] ).

%% Accessors
id( #{ id := ID } )										-> ID.
url( #{ url := URL } )									-> URL.
config_url( #{ config := #{ url := URL } } )			-> URL.
content_type( #{ config := #{ content_type := C } } )	-> C.
name( #{ name := Name } )								-> Name.
events( #{ events := Events } )							-> Events.
active( #{ active := Active } )							-> Active.
config( #{ config := Config } )							-> Config.
test_url( #{ test_url := URL } )						-> URL.
ping_url( #{ ping_url := URL } )						-> URL.
updated_at( #{ updated_at := D } )						-> D.
created_at( #{ created_at := D } )						-> D.

-spec make( id(), binary(), binary(), name(), [event()] ) -> hook().
make( ID, URL, ContentType, Name, Events ) ->
	#{ id => ID, name => Name, config => #{ url => URL, content_type => ContentType }, events => Events }.

%%
%%	List all hooks installed under the given repository
%%
-spec list( binary(), binary(), gh:state() ) -> { ok, [hook()] } | { error, term() }.
list( Owner, Repo, State ) ->
	gh_request:get( ["repos", Owner, Repo, "hooks" ], State ).
	
-spec list( gh:repository(), gh:state() ) -> { ok, [hook()] } | { error, term() }.
list( Repository, State ) ->
	list( gh_repo:owner( Repository ), gh_repo:name( Repository ), State ).
	
	
%%
%%	Get the hook with the specified ID in the given repository
%%
-spec by_id( gh_repo:owner(), gh_repo:name(), id(), gh:state() ) -> { ok, hook() } | { error, term() }.
by_id( Owner, Repo, ID, State ) when is_integer( ID ) ->
	by_id( Owner, Repo, integer_to_binary( ID ), State );
	
by_id( Owner, Repo, ID, State ) ->
	gh_request:get( ["repos", Owner, Repo, "hooks", ID ], State ).
	
-spec by_id( gh:repository(), id(), gh:state() ) -> { ok, hook() } | { error, term() }.
by_id( Repository, ID, State ) ->
	by_id( gh_repo:owner( Repository ), gh_repo:name( Repository ), ID, State ).
	

%%
%%	Find all hooks with the given name in the specified repository
%%
-spec by_name( gh_repo:owner(), gh_repo:name(), name(), gh:state() ) -> { ok, [hook()] } | { error, term() }.
by_name( Owner, Repo, HookName, State ) ->
	case list( Owner, Repo, State ) of
		{ ok, Hooks } -> 
			HName = want:binary( HookName ),
			{ ok, lists:filter( fun( #{ name := Name } ) -> Name == HName end, Hooks ) };
		
		{ error, Reason } -> 
			{ error, Reason }
	end.

-spec by_name( gh:repository(), name(), gh:state() ) -> { ok, [hook()] } | { error, term() }.
by_name( Repo, HookName, State ) ->
	by_name( gh_repo:owner( Repo ), gh_repo:name( Repo ), HookName, State ).	


%%
%%	Find the hook with the given URL in the specified repository
%%
-spec by_url( gh_repo:owner(), gh_repo:name(), binary(), gh:state() ) -> { ok, hook() } | { error, term() }.
by_url( Owner, Repo, URL, State ) ->
	case list( Owner, Repo, State ) of
		{ ok, Hooks } -> 
			UB = want:binary( URL ),
			case lists:filter( fun( #{ config := #{ url := U } } ) -> U == UB end, Hooks ) of
				[Hook]	-> { ok, Hook };
				[] 		-> { error, not_found };
				Hooks 	-> { ok, Hooks }
			end;
		
		{ error, Reason } -> 
			{ error, Reason }
	end.

-spec by_url( gh:repository(), binary(), gh:state() ) -> { ok, hook() } | { error, term() }.
by_url( Repo, URL, State ) ->
	by_url( gh_repo:owner( Repo ), gh_repo:name( Repo ), URL, State ).

%%
%%	Create a hook under the given repository
%%
-spec create( gh_repo:owner(), gh_repo:name(), name(), binary(), binary(), [event()], boolean(), gh:state() ) -> { ok, hook() } | { error, term() }.
create( Owner, Repo, HookName, URL, ContentType, Events, Active, State ) ->
	JSON = #{ 	name => want:binary( HookName ), 
				config => #{ 
					url 			=> want:binary( URL ), 
					content_type 	=> want:binary( ContentType ) }, 
				events => [ want:binary( E ) || E <- Events ], 
				active => want:boolean( Active ) },
	case gh_request:post( ["repos", Owner, Repo, "hooks" ], JSON, State ) of
		{ ok, Hook }				-> { ok, Hook };
		{ error, { 422, _, _ } }	-> by_url( Owner, Repo, URL, State );
		{ error, { _, Reason, _ } }	-> { error, Reason };
		{ error, Reason }			-> { error, Reason }
	end.
	
-spec create( gh:repository(), name(), binary(), binary(), [event()], boolean(), gh:state() ) -> { ok, hook() } | { error, term() }.
create( Repository, HookName, URL, ContentType, Events, Active, State ) ->
	create( gh_repo:owner( Repository ), gh_repo:name( Repository ), HookName, URL, ContentType, Events, Active, State ).
	
%%
%%	Create a webhook under the given repository
%%
-spec create_web( gh_repo:owner(), gh_repo:name(), binary(), binary(), [event()], boolean(), gh:state() ) -> { ok, hook() } | { error, term() }.
create_web( Owner, Repo, URL, ContentType, Events, Active, State ) ->
	create( Owner, Repo, ?WEB_HOOK_NAME, URL, ContentType, Events, Active, State ).
	
-spec create_web( gh:repository(), binary(), binary(), [event()], boolean(), gh:state() ) -> { ok, hook() } | { error, term() }.
create_web( Repository, URL, ContentType, Events, Active, State ) ->
	create_web( gh_repo:owner( Repository ), gh_repo:name( Repository ), URL, ContentType, Events, Active, State ).


%%
%%	Delete the hook with the given ID from the repository
%%
-spec delete( gh_repo:owner(), gh_repo:name(), id(), gh:state() ) -> ok | { error, term() }.
delete( Owner, Repo, ID, State ) ->
	case gh_request:delete( [ "repos", Owner, Repo, "hooks", want:string( ID ) ], State ) of
		{ ok, _ }			-> ok;
		{ error, Reason }	-> { error, Reason }
	end.
	
-spec delete( gh:repository(), id(), gh:state() ) -> ok | { error, term() }.
delete( Repository, ID, State ) ->
	delete( gh_repo:owner( Repository ), gh_repo:name( Repository ), ID, State ).