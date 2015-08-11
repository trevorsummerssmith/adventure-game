open Core.Std

type message =
  { player : Uuid.t
  ; time   : Time.t
  ; text   : string
  } with sexp, compare

type t with sexp, compare

val create :
  trees:int
  -> rocks:int
  -> players:Uuid.t list
  -> messages:message list
  -> t

val from :
  ?trees:int
  -> ?rocks:int
  -> ?players:Uuid.t list
  -> ?messages:message list
  -> t
  -> t

val empty : t

val trees : t -> int
val rocks : t -> int
val players : t -> Uuid.t list
val messages : t -> message list
