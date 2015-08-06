open Core.Std

type op =
  | AddTree
  | RemoveTree
  | AddRock
  | RemoveRock with sexp

type t =
  { posn : Posn.t
  ; op : op
  } with sexp
