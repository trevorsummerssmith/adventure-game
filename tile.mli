open Core.Std

type t with sexp, compare

val create : trees:int -> rocks:int -> players:Uuid.t list -> t

val from : ?trees:int -> ?rocks:int -> ?players:Uuid.t list -> t -> t

val empty_tile : t

val trees : t -> int
val rocks : t -> int
val players : t -> Uuid.t list
