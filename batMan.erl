%% @author Dries Brans
%% @copyright 2018 Dries Brans
%% @version 1.0.0
%% @doc
%% A erlang implementation of my project program
%% for the Raspberry Pi.
%% @end

% battery management (batMan :D)
-module(batMan).
-export([start/0, init/2, stop/2, batCheck/2]).
-author('Dries Brans').


init_out() ->
    Out1 = gpio:init(17, out),	% BAT/GEN
    Out2 = gpio:init(27, out),	% VER
    {Out1, Out2}.

init_in() ->
    In1 = gpio:init(19, in),	% BAT_Low
    In2 = gpio:init(26, in),	% BAT_High
    In3 = gpio:init(13, in),	% test GEN
    {In1, In2, In3}.

stop(Outputs, Inputs) ->
    gpio:stop(element(1, Outputs)),
    gpio:stop(element(2, Outputs)),
    gpio:stop(element(1, Inputs)),
    gpio:stop(element(2, Inputs)),
    gpio:stop(element(3, Inputs)),
    io:format("\ec"),
    io:fwrite("Program stopped!~n"),
    logbook:entry("STOP").

start() ->
    Outputs = init_out(),
    Inputs = init_in(),

    gpio:write(element(1, Outputs), 0),
    gpio:write(element(2, Outputs), 0),

    {Outputs, Inputs}.

init(Outputs, Inputs) ->
    logbook:start(),
    Pid = spawn(?MODULE, batCheck, [Outputs, Inputs]),
    Pid.


batCheck(Outputs, Inputs) ->
    case gpio:read(element(1, Inputs)) of	% BAT spanning controleren

    	"0" -> io:format("\ec"),
	       io:fwrite("BAT niveau voldoende, spanning boven 3.6V.~n"),
	       gpio:write(element(2, Outputs), 1),
	       timer:sleep(100),
	       batCheck(Outputs, Inputs);
	     
	"1" -> io:format("\ec"),
	       io:fwrite("BAT niveau onvoldoende, spanning onder 3.6V.~n"),
               logbook:entry("BAT LOW"),
	       gpio:write(element(2, Outputs), 0),
	       timer:sleep(2000),
	       genCheck(Outputs, Inputs)
    end.


genCheck(Outputs, Inputs) ->
    case gpio:read(element(3, Inputs)) of	% kijken of GEN actief is

    	"1" -> io:format("\ec"),
               io:fwrite("GEN is actief.~n"),
	       io:fwrite("BAT is nog niet opgeladen.~n"),
      	       logbook:entry("BAT CHARGE"),
	       timer:sleep(2000),
	       batCharge(Outputs, Inputs);
	     
	"0" -> io:format("\ec"),
   	       io:fwrite("GEN is niet actief, wacht tot GEN actief is!~n"),
	       logbook:entry("GEN NOT ACTIVE"),
	       gpio:write(element(1, Outputs), 0),
	       timer:sleep(2000),
	       genCheck(Outputs, Inputs)
    end.

batCharge(Outputs, Inputs) ->
    case gpio:read(element(2, Inputs)) of	% kijken of BAT opgeladen is

    	"1" -> io:format("\ec"),
               io:fwrite("BAT is opgeladen.~n"),
	       logbook:entry("BAT HIGH"),
	       gpio:write(element(1, Outputs), 0),
	       timer:sleep(2000),
	       batCheck(Outputs, Inputs);
	     
	"0" -> gpio:write(element(1, Outputs), 1),
	       timer:sleep(100),
	       genCheck(Outputs, Inputs)
    end.