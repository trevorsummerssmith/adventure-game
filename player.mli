open Core.Std

type t with sexp, compare

val create :
  ?id:Uuid.t
  -> resources:Resources.t
  -> name:string
  -> posn:Posn.t
  -> t

(** Functional updates *)

val with_resources : t -> Resources.t -> t

val move : t -> Posn.t -> t

(** Getters *)

val name : t -> string

val posn : t -> Posn.t

val id : t -> Uuid.t

val resources : t -> Resources.t
