-module( gh_organization ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [by_user/1, by_user/2, by_name/2] ).

-type organization() :: map().
-export_type( [organization/0] ).

%%
%%	List all organizations to which the authenticated user belongs
%%
-spec by_user( gh:state() ) -> { ok, [organization()] } | { error, term() }.
by_user( State ) ->
	gh_request:get( ["user", "orgs"], State ).

%%
%%	Get all organizations to which the given user belongs
%%
-spec by_user( string(), gh:state() ) -> { ok, [organization()] } | { error, term() }.
by_user( User, State ) ->
	gh_request:get( ["users", User, "orgs"], State ).
	
%%
%%	Get the organization with the given name
%%
-spec by_name( string(), gh:state() ) -> { ok, [organization()] } | { error, term() }.
by_name( Name, State ) ->
	case gh_request:get( ["orgs", Name], State ) of
		{ ok, Organization } 		-> { ok, Organization };
		{ error, { 404, _, _ }	}	-> { error, not_found };
		{ error, Reason }			-> { error, Reason }
	end.