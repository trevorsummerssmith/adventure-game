open Core.Std

type t

val create : Game.t -> t

val step : t -> unit

val run : t -> unit

val add_op : t -> Game_op.t -> unit Or_error.t
(** Adds a new operation to the game. All of the games validation checks are
    here. If a validation check fails the op is not added and an error is
    returned.

    The op is not run, just added.
*)

val get_tile : t -> Posn.t -> Tile.t

val players : t -> (Uuid.t, Player.t) Hashtbl.t

val dimensions : t -> Posn.t
