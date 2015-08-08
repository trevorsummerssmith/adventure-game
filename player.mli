open Core.Std

type t with sexp

val create : ?id:Uuid.t -> name:string -> posn:Posn.t -> t

val move : t -> Posn.t -> t

val name : t -> string

val posn : t -> Posn.t

val id : t -> Uuid.t

