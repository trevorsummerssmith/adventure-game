open Core.Std

type op =
  | Add_player of string * Uuid.t option
  (* Player name
     This op will create a new id for the player to be used in
     all subsequent player ops *)
  | Move_player of Uuid.t
  | Add_tree
  | Remove_tree
  | Add_rock
  | Remove_rock with sexp

type t =
  { posn : Posn.t
  ; op : op
  } with sexp

let create op posn =
  {op; posn}
