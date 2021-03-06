-module(nolimit_writer).
-compile(export_all).

-include_lib("bitcask/include/bitcask.hrl").

write_proc(Ref) ->
  receive
    {write, Key, Value} ->
      bitcask:put(Ref, term_to_binary(Key), term_to_binary([Value, 0, nolimit_ttl:epoch_seconds()])),
      nolimit_writer:write_proc(Ref);
    {write, Key, Value, RawSeconds} ->
      {Seconds, _} = string:to_integer(RawSeconds),
      bitcask:put(Ref, term_to_binary(Key), term_to_binary([Value, Seconds, nolimit_ttl:epoch_seconds()])),
      nolimit_writer:write_proc(Ref);
    {delete, Key} ->
      bitcask:delete(Ref, term_to_binary(Key)),
      nolimit_writer:write_proc(Ref)
  end.

start_writer() ->
    Pid = spawn_link(fun() ->
          Ref = bitcask:open("nolimit.cask", [read_write]),
          nolimit_writer:write_proc(Ref)
      end),
    Pid.
