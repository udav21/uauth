-module(users_h).
-behaviour(cowboy_rest).


%% REST Callbacks
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([is_authorized/2]).

%% Callback Callbacks
-export([to_json/2, from_json/2]).

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

%-spec is_authorized(Req, State) -> {Result, Req, State}
%Result  :: true | {false, AuthHeader :: iodata()}
%Default  - true
is_authorized(Req, State) ->
    case cowboy_req:parse_header(<<"authorization">>, Req) of
        {bearer, Token} -> 
            case persist:is_user(Token) of % <--- Лажа.
                true  -> {true , Req, State};
                false -> {false, Req, State}
            end;
        _ -> false
    end.

to_json(Req, State) ->
    Message = [greeting, <<"Hi there!">>],
    Body = jiffy:encode(Message, [pretty]),
    {Body, Req, State}.

from_json(Req, State) ->
    {ok, Req, State}.         % STUB