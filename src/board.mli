open Core.Std

type t =
  { board : Entity.Id.t array array
  (** Mapping from board x,y to tile's entity id *)
  ; dimensions : Posn.t
  } with sexp

val create : Posn.t -> t
(** [create posn] makes a new board with a new uuid for each tile. *)

val get : t -> Posn.t -> Entity.Id.t

val mapi : t -> f:(int -> int -> Entity.Id.t -> 'a) -> 'a array array
