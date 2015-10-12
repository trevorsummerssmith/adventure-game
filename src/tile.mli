open Core.Std

type t = Entity.t with sexp_of

val create
  : ?id:Uuid.t
  -> resources:Resources.t
  -> players:Entity.Id.t list
  -> messages:Message.t list
  -> extants:Atoms.extant list
  -> unit
  -> t

val shallow_compare : t -> t -> int
(** Compares all fields except id *)

val empty : t
