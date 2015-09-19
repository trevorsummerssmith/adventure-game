open Core.Std

(** All accessor functions are defined in [Props].
    The required fields are all set in [Player.create].
    There are no optional fields.
*)

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
(** [create ?id ?buildables ?artifacts resources posn name] *)
