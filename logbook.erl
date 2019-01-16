-module(logbook).
-export([start/0, entry/1, init/0]).

start() ->
    register(logbook, spawn(?MODULE, init, [])).

entry(Data) -> 
    ets:insert(logboek, {{now(), self()}, date(), time(), Data}).

init() ->
    ets:new(logboek, [named_table, ordered_set, public]),
    loop().

loop() -> 
    receive
	stop -> ok
    end.