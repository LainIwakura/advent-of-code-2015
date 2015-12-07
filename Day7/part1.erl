-module(part1).
-export([main/0]).

main() ->
	ets:new(circuits, [set,public,named_table]),
	create_circuits(readlines("input")),
	io:format("~p~n", [val("a")]).

readlines(Filename) ->
	{ok, Data} = file:read_file(Filename),
	[string:tokens(erlang:binary_to_list(Str), "-> ") || 
	 	Str <- (binary:split(Data, [<<"\n">>], [global]) -- [<<>>])].

create_circuits(Schematics) ->
	lists:foreach(fun(X) ->
		{In, Op} = {hd(lists:reverse(X)), lists:droplast(X)},
		ets:insert(circuits, {In, Op})
	end, Schematics).

val(X) ->
	R = case string:to_integer(X) of
			{error, _} ->
				case ets:lookup(circuits, X) of
					[{_, Res}] when is_integer(Res) -> Res;
					[{_, L}] when is_list(L) -> parse(L)
				end;
			{Res, _} -> Res
	end,
	ets:insert(circuits, {X, R}),
	R.


parse([X]) -> val(X);
parse(["NOT", X]) -> bnot val(X);
parse([X, "AND", Y]) -> val(X) band val(Y);
parse([X, "OR", Y]) -> val(X) bor val(Y);
parse([X, "LSHIFT", Y]) -> val(X) bsl val(Y);
parse([X, "RSHIFT", Y]) -> val(X) bsr val(Y).
