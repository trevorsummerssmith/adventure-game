open Core.Std

type t

val create : Game.t -> t

val step : t -> unit

val run : t -> unit

val get_tile : t -> Posn.t -> Tile.t

val players : t -> (Uuid.t, Player.t) Hashtbl.t
