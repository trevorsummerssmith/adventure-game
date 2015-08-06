open Core.Std

type t =
  { trees : int
  ; rocks : int
  } with sexp, compare

let empty_tile = {trees=0;rocks=0}
