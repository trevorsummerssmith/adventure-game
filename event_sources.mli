open Core.Std
open Async.Std

(**
   Right now this module is a functional grouping, of things that create
   ops, and are given as callbacks to Dyanmo.run_event_source

   This isn't a particularly good grouping and so I imagine we'll do something
   else with it later. However, for the moment we need to test this stuff, and this
   works.
*)

val update_buildable :
  ?after:(Time.Span.t -> unit Deferred.t)
  -> Uuid.t
  -> Game_op.t Pipe.Writer.t
  -> unit Or_error.t Pipe.Reader.t
  -> unit Deferred.t
(** [update_buildable ?after id w_op r_resp] updates the buildable [id]
    every 10s by by 10 percent. By producing [Game_op.Buildable_update] events.
    When it is over 99 percent it is marked [Complete], and the function terminates.

    [after] is dependency injected so we can test.
*)
