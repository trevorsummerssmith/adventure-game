open Core.Std

(** A message is some text that a player can speak
    at a given time.
*)

type t =
  { player_id : Entity.Id.t
  ; time      : Time.t
  ; text      : string
  } with sexp, compare
