open Core.Std
open Async.Std

type t

val create : Game.t -> t

val step : t -> unit

val run : t -> unit

val run_event_source : t
  -> f:(Game_op.t Pipe.Writer.t
        -> unit Or_error.t Pipe.Reader.t
        -> unit Deferred.t)
  -> unit
(** [run_event_source f] [f] will write ops to the writer. The op will be
    validated. If the validation result is ok the dynamo will be [step]ped.
    If the validation fails the op will not be added. In either case, the
    Or_error will be written back to the response pipe.

    N.B. The pipes have the default pushback so [f] MUST read the result
    after writing.
*)

val add_op : t -> Game_op.t -> unit Or_error.t
(** Adds a new operation to the game. All of the games validation checks are
    here. If a validation check fails the op is not added and an error is
    returned.

    The op is not run, just added.
*)

val get_tile : t -> Posn.t -> Tile.t

val players : t -> (Uuid.t, Player.t) Hashtbl.t

val dimensions : t -> Posn.t

val game : t -> Game.t

val board : t -> Board.t

val artifacts : t -> (Uuid.t, Things.artifact) Hashtbl.t

val buildables : t -> (Uuid.t, Things.Buildable.t) Hashtbl.t

val store : t -> Entity_store.t
