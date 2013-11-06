-module(lager_console).

%% This module contains convenience methods for interactions with lager_console_backend

-export([
	trace/2, trace/3,
	remove_trace/1, remove_trace/2,
	clear_traces/0,
	list_traces/0
]).

trace(Module, Level) ->
	{ok, _} = lager:trace_console([{module, Module}], Level),
	list_traces().

trace(Module, Function, Level) ->
	{ok, _} = lager:trace_console([{module,Module}, {function, Function}], Level),
	list_traces().

remove_trace(Module) ->
	Traces = console_traces(),
	ClearTraces = lists:filter(
		fun({{_,Filter},_,_}) ->
			lists:member({module, '=', Module}, Filter)
		end, Traces),
	remove_traces(ClearTraces),
	list_traces().

remove_trace(Module, Function) ->
	Traces = console_traces(),
	ClearTraces = lists:filter(
		fun({{_,Filter},_,_}) ->
			lists:member({module, '=', Module}, Filter) andalso
				lists:member({function, '=', Function}, Filter)
		end, Traces),
	remove_traces(ClearTraces),
	list_traces().

clear_traces() ->
	Traces = console_traces(),
	remove_traces(Traces),
	list_traces().

list_traces() ->
	Traces = console_traces(),
	ConsoleTraces = [{Filter, lager_util:mask_to_levels(M)} || {{_, Filter}, {mask,M}, _} <- Traces],
	{ok, ConsoleTraces}.


%%Private

console_traces() ->
	[T || {_,_,lager_console_backend}=T <- element(2,lager_config:get(loglevel))].

remove_traces(Traces) ->
	[lager:stop_trace(T) || T <- Traces].
