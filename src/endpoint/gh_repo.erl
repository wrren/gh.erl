-module( gh_repo ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [list/1, branches/2] ).
-export( [id/1, name/1, git_url/1, ssh_url/1, clone_url/1, private/1] ).

-type repository()  :: map().
-type branch()      :: map().

-export_type( [repository/0, branch/0] ).

%%
%%  List all repositories accessible to the authenticated user.
%%
-spec list( gh:state() ) -> { ok, gh_request:json() } | { error, term() }.
list( State ) ->
    gh_request:get( ["user", "repos"], State ).
  
%%
%%  List all branches for the given repository
%%
-spec branches( repository(), gh:state() ) -> [ branch() ].
branches( #{ owner := #{ login := Owner }, name := Name }, State ) ->
    gh_request:get( ["repos", Owner, Name, "branches" ], State ).
   
%% Repository ID
id( #{ id := ID } )                     -> ID.
%% Repository descriptive name
name( #{ name := Name } )               -> Name.
%% Get the git:// scheme URL for this repository
git_url( #{ git_url := GitUrl } )       -> GitUrl.
%% Get the ssh:// scheme URL for this repository
ssh_url( #{ ssh_url := SSHUrl } )       -> SSHUrl.
%% Get a URL suitable for passing to git clone 
clone_url( #{ clone_url := CloneUrl } ) -> CloneUrl.
%% Check whether the repository is marked as private
private( #{ private := "true" } )       -> true;
private( #{ private := "false" } )      -> false;
private( #{ private := Private } )      -> Private.