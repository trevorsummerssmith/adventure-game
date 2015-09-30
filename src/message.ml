open Core.Std

type t =
  { player_id : Entity.Id.t
  ; time      : Time.t
  ; text      : string
  } with sexp, compare
