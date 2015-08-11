open Core.Std

type code =
  | Add_player of string * Uuid.t option
  (* Player name
     This op will create a new id for the player to be used in
     all subsequent player ops *)
  | Move_player of Uuid.t
  | Player_message of Uuid.t * Time.t * string
  (* Player id, time message occurred in utc, message *)
  | Add_tree
  | Remove_tree
  | Add_rock
  | Remove_rock with sexp

type t =
  { posn : Posn.t
  ; code : code
  } with sexp

let create code posn =
  {code; posn}
