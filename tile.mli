open Core.Std

type t with sexp, compare

val create : trees:int -> rocks:int -> t

val from : ?trees:int -> ?rocks:int -> t -> t

val empty_tile : t

val trees : t -> int
val rocks : t -> int
