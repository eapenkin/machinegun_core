%%%
%%% Copyright 2019 RBKmoney
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%%

-module(mg_procreg_gproc).

%%

-behaviour(mg_procreg).

-export([ref/2]).
-export([reg_name/2]).
-export([all/1]).

-export([start_link/5]).
-export([call/4]).

-export([start_supervisor/4]).

-type options() :: undefined.

%%

-spec ref(options(), mg_procreg:name()) ->
    mg_procreg:ref().
ref(_Options, Name) ->
    {via, gproc, {n, l, Name}}.

-spec reg_name(options(), mg_procreg:name()) ->
    mg_procreg:reg_name().
reg_name(Options, Name) ->
    ref(Options, Name).

-spec all(options()) ->
    [{mg_procreg:name(), pid()}].
all(_Options) ->
    lists:map(
        fun erlang:list_to_tuple/1,
        gproc:select([{{{n, l, '$1'}, '$2', '_'}, [], [['$1', '$2']]}])
    ).

-spec start_link(options(), mg_procreg:reg_name(), module(), _Args, list()) ->
    mg_procreg:start_link_ret().
start_link(_Options, RegName, Module, Args, Opts) ->
    gen_server:start_link(RegName, Module, Args, Opts).

-spec call(options(), mg_procreg:ref(), _Call, timeout()) ->
    _Reply.
call(_Options, Ref, Call, Timeout) ->
    gen_server:call(Ref, Call, Timeout).

-spec start_supervisor(
    options(),
    mg_procreg:name(),
    supervisor:sup_flags(),
    [supervisor:child_spec()]
) ->
    mg_procreg:start_supervisor_ret().
start_supervisor(Options, Name, SupFlags, ChildSpecs) ->
    mg_utils_supervisor_wrapper:start_link(reg_name(Options, Name), SupFlags, ChildSpecs).
