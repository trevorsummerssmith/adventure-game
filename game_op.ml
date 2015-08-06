open Core.Std

type op =
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
