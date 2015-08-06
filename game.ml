open Core.Std

type t =
  { ops : Game_op.t list
  ; board_dimensions : Posn.t
  } with sexp
