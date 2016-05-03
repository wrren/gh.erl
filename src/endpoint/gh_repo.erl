-module( gh_repo ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [list/1, by_name/3] ).
-export( [id/1, make/7, owner/1, name/1, git_url/1, ssh_url/1, clone_url/1, private/1] ).

-type owner()       :: binary().
-type name()        :: binary().
-type repository()  :: map().
-type branch()      :: map().

-export_type( [owner/0, name/0, repository/0, branch/0] ).

%%
%%  List all repositories accessible to the authenticated user.
%%
-spec list( gh:state() ) -> { ok, [repository()] } | { error, term() }.
list( State ) ->
    gh_request:get( ["user", "repos"], State ).

%%
%%  Given an owner name and a repository name, get information on the repository
%%
-spec by_name( string(), string(), gh:state() ) -> { ok, repository() } | { error, term() }.
by_name( Owner, Name, State ) ->
    gh_request:get( ["repos", Owner, Name], State ).

%% Repository ID
id( #{ id := ID } )                         -> ID.
%% Repository Owner Name
owner( #{ owner := #{ login := Owner } } )  -> Owner.
%% Repository descriptive name
name( #{ name := Name } )                   -> Name.
%% Get the git:// scheme URL for this repository
git_url( #{ git_url := GitUrl } )           -> GitUrl.
%% Get the ssh:// scheme URL for this repository
ssh_url( #{ ssh_url := SSHUrl } )           -> SSHUrl.
%% Get a URL suitable for passing to git clone 
clone_url( #{ clone_url := CloneUrl } )     -> CloneUrl.
%% Check whether the repository is marked as private
private( #{ private := "true" } )           -> true;
private( #{ private := "false" } )          -> false;
private( #{ private := Private } )          -> Private.

%%
%%  Generate a map with a format matching that of a decoded repository JSON blob, useful for testing
%%  without knowledge of map internals.
%%
-spec make( pos_integer(), binary(), binary(), binary(), binary(), binary(), boolean() ) -> repository().
make( ID, Owner, Name, GitUrl, SSHUrl, CloneUrl, Private ) ->
    #{  id          => ID,
        owner       => #{ login => Owner },
        name        => Name,
        git_url     => GitUrl,
        ssh_url     => SSHUrl,
        clone_url   => CloneUrl,
        private     => Private }.