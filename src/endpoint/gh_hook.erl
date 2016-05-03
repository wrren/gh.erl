-module( gh_hook ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

%% Queries
-export( [	list/2, list/3, 
			by_id/3, by_id/4, 
			create/7, create/8, 
			delete/3, delete/4] ).
%% Accessors
-export( [ 	id/1, url/1, test_url/1, ping_url/1, name/1, events/1, active/1, config/1, 
			updated_at/1, created_at/1] ).

-type id() 		:: binary() | pos_integer().
-type event() 	:: binary().
-type name() 	:: binary().
-type hook() 	:: map().
-export_type( [id/0, hook/0, name/0, event/0] ).

%% Accessors
id( #{ id := ID } )					-> ID.
url( #{ url := URL } )				-> URL.
name( #{ name := Name } )			-> Name.
events( #{ events := Events } )		-> Events.
active( #{ active := Active } )		-> Active.
config( #{ config := Config } )		-> Config.
test_url( #{ test_url := URL } )	-> URL.
ping_url( #{ ping_url := URL } )	-> URL.
updated_at( #{ updated_at := D } )	-> D.
created_at( #{ created_at := D } )	-> D.

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
%%	Create a hook under the given repository
%%
-spec create( gh_repo:owner(), gh_repo:name(), name(), binary(), binary(), [event()], boolean(), gh:state() ) -> { ok, hook() } | { error, term() }.
create( Owner, Repo, HookName, URL, ContentType, Events, Active, State ) ->
	JSON = #{ 	name => gh_want:binary( HookName ), 
				config => #{ 
					url 			=> gh_want:binary( URL ), 
					content_type 	=> gh_want:binary( ContentType ) }, 
				events => [ gh_want:binary( E ) || E <- Events ], 
				active => gh_want:boolean( Active ) },
	gh_request:post( ["repos", Owner, Repo, "hooks" ], JSON, State ).
	
-spec create( gh:repository(), name(), binary(), binary(), [event()], boolean(), gh:state() ) -> { ok, hook() } | { error, term() }.
create( Repository, HookName, URL, ContentType, Events, Active, State ) ->
	create( gh_repo:owner( Repository ), gh_repo:name( Repository ), HookName, URL, ContentType, Events, Active, State ).

%%
%%	Delete the hook with the given ID from the repository
%%
-spec delete( gh_repo:owner(), gh_repo:name(), id(), gh:state() ) -> ok | { error, term() }.
delete( Owner, Repo, ID, State ) ->
	case gh_request:delete( [ "repos", Owner, Repo, "hooks", ID ], State ) of
		{ ok, _ }			-> ok;
		{ error, Reason }	-> { error, Reason }
	end.
	
-spec delete( gh:repository(), id(), gh:state() ) -> ok | { error, term() }.
delete( Repository, ID, State ) ->
	delete( gh_repo:owner( Repository ), gh_repo:name( Repository ), ID, State ).