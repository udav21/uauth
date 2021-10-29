%%%-------------------------------------------------------------------
%% @doc uauth public API
%% @end
%%%-------------------------------------------------------------------

-module(uauth_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
%% ----------------------------------------
%% pre-MySQL apps
%% ----------------------------------------
    application:start(sasl),
	crypto:start(),
%% ----------------------------------------
    application:start(emysql),

	emysql:add_pool(portal_pool, [{size,1},
				     {user,"portal_admin"},
				     {password,"admin"},
				     {database,"users"},
				     {encoding,utf8}]),
    
%   CREATE DATABASE `users` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */
%   CREATE TABLE `users` (
%       `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
%       `login` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
%       `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
%       `pwd_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
%       `salt` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
%       `active` tinyint(1) NOT NULL DEFAULT 1,
%       PRIMARY KEY (`id`),
%       UNIQUE KEY `email_UN` (`email`),
%       UNIQUE KEY `login_UN` (`login`),
%       KEY `users_login_IDX` (`login`) USING BTREE
%     ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Таблица пользователей портала'

%% --------------------------------------------------------
%% Cowboy start
%% --------------------------------------------------------
    Dispatch = cowboy_router:compile([         
        {'_', [
                 {"/"        , index_h     , []}
                %,{"/register", register_h  , []}
                %,{"/login"   , login_h     , []}
                %,{"/logout"  , logout_h    , []}
                 ,{"/users"   , users_h    , []}
              ]
        }     
    ]),     
    {ok, _} = cowboy:start_clear( % разобраться с TLS сертификатами для start_tls
        http_listener,
         [{port, 8080}],
         #{env => #{dispatch => Dispatch}}
    ),

    uauth_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
