open Core.Std

(** Random entities that are small and don't have functionality *)

module Artifact : sig
  type t = Entity.t with sexp_of

  val create
    : ?id:Entity.Id.t
    -> player_id:Entity.Id.t
    -> text:string
    -> unit
    -> t
end

module Buildable : sig

  type t = Entity.t with sexp_of

  val create
    : ?id:Entity.Id.t
    -> percent_complete:Atoms.percent_complete
    -> kind:Atoms.kind
    -> unit
    -> t
end

module Temple : sig
  type t = Entity.t with sexp_of

  val create
    : ?id:Entity.Id.t
    -> name:string
    -> text:string
    -> posn:Posn.t
    -> locked:bool
    -> unit
    -> t
    (** The temple [text] is a secret and only exposed once the temple
        is unlocked *)
end
