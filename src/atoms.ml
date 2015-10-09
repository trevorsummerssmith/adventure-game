open Core.Std

type percent_complete =
  | Building of int
  | Complete with sexp, compare

type kind =
  | Artifact of Entity.Id.t with sexp_of
