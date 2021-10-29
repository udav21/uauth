-module(persist).
-export([
         create_user/3
        ,is_user/1
        ,is_user_active/1
        ,delete_user/1
        ,activate_user/1
        ,deactivate_user/1
        ,change_user_name/2
        ,change_user_pass/2
        ,change_user_mail/2
        ]).

create_user(Login, Pwd, Email) ->
    Salt = integer_to_list(rand:ununiform(1000000)), % может, использовать мэйл как соль лучше и проще?
    PwdHash = crypto:hash(sha3_512, Pwd ++ Salt),
	emysql:execute(
                   portal_pool, 
                   <<"INSERT INTO users (login, email, pwd_hash, salt, active) VALUES ?, ?, ?, ?, ?">>, 
                   [Login, Email, PwdHash, Salt, 1]
                  ).

is_user(Login) ->
    emysql:prepare(stmt, <<"SELECT * FROM users WHERE login = ?">>),
    {_, _, _, Result, _} = emysql:execute(portal_pool, stmt, [Login]),
    case Result of           % корявенькая проверка (очень). Как затычка.
        [] -> false;
        _  -> true
    end.

is_user_active(Login) ->
    emysql:prepare(stmt, <<"SELECT * FROM users WHERE login = ? AND active = 1">>),
    {_, _, _, Result, _} = emysql:execute(portal_pool, stmt, [Login]),
    case Result of           % корявенькая проверка (очень). Как затычка.
        [] -> false;
        _  -> true
    end.

delete_user(Login) ->
    emysql:prepare(stmt, <<"DELETE * FROM users WHERE login = ?">>),
    emysql:execute(portal_pool, stmt, [Login]).
% возвращает {ok_packet,1,1,0,2,0,[]}. С чем матчить?
        

activate_user(Login) ->
    emysql:prepare(stmt, <<"UPDATE users SET active = 1 WHERE login = ?">>),
    emysql:execute(portal_pool, stmt, [Login]).

deactivate_user(Login) ->
    emysql:prepare(stmt, <<"UPDATE users SET active = 0 WHERE login = ?">>),
    emysql:execute(portal_pool, stmt, [Login]).

change_user_name(Login, NewLogin) ->
    emysql:prepare(stmt, <<"UPDATE users SET login = ? WHERE login = ?">>),
    emysql:execute(portal_pool, stmt, [NewLogin, Login]).

change_user_pass(Login, NewPass) ->
    Salt = integer_to_list(rand:ununiform(1000000)), % может, использовать мэйл как соль лучше и проще?
    PwdHash = crypto:hash(sha3_512, NewPass ++ Salt),
	emysql:execute(
                   portal_pool, 
                   <<"UPDATE users SET pwd_hash = ? WHERE login = ?">>, 
                   [PwdHash, Login]
                  ).

change_user_mail(Login, Mail) ->
    emysql:prepare(stmt, <<"UPDATE users SET email = ? WHERE login = ?">>),
    emysql:execute(portal_pool, stmt, [Mail, Login]).