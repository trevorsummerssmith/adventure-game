open Core.Std

type kind =
  | Wood
  | Rock with sexp, compare

type t with sexp, compare

val empty : t

val of_alist_exn : (kind, int) List.Assoc.t -> t

(** Functional updates *)

val incr : t -> kind:kind -> t

val decr : t -> kind:kind -> t
(* This is allowed to become < 0 *)

(** Accessors *)

val get : t -> kind:kind -> int
