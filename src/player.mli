open Core.Std

type t with sexp, compare

val create :
  ?id:Uuid.t
  -> ?buildables:Uuid.t list
  -> ?artifacts:Uuid.t list
  -> resources:Resources.t
  -> posn:Posn.t
  -> string
  -> t

(** Functional updates *)

val with_buildables : t -> Uuid.t list -> t

val with_resources : t -> Resources.t -> t

val with_artifacts : t -> Uuid.t list -> t

val move : t -> Posn.t -> t

(** Getters *)

val name : t -> string

val posn : t -> Posn.t

val id : t -> Uuid.t

val resources : t -> Resources.t

val buildables : t -> Uuid.t list

val artifacts : t -> Uuid.t list
