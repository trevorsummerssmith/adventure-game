open Core.Std

type t = Entity.t with sexp_of

val compare : t -> t -> int

val create :
  ?id:Uuid.t
  -> ?buildables:Uuid.t list
  -> ?artifacts:Uuid.t list
  -> resources:Resources.t
  -> posn:Posn.t
  -> string
  -> t

(* TODO idea keep props in module?

module Props : sig
  val name : string Entity_store.Prop.t
  val posn : Posn.t Entity_store.Prop.t
  val resources : Resources.t Entity_store.Prop.t
  val buildables : Uuid.t list Entity_store.Prop.t
  val artifacts : Uuid.t list Entity_store.Prop.t
   end*)

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
