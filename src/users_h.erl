-module(users_h).
-behaviour(cowboy_rest).


%% REST Callbacks
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).

%% Callback Callbacks
-export([to_json/2]).

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->  
    {[
         <<"POST">>   % new user (registration)
        ,<<"GET">>    % is registered, get info etc
        ,<<"PUT">>    % change password or email
        ,<<"DELETE">> % delete user
     ], Req, State}.

content_types_accepted(Req, State) ->
    {[
        {<<"application/json">>, from_json}
    ], Req, State}.

content_types_provided(Req, State) ->
    {[
        {{<<"application/json">>, []}, to_json}
    ], Req, State}.

to_json(Req, State) ->
    Message = [greeting, <<"Hi there!">>],
    {jiffy:encode(Message, [pretty]), Req, State}.