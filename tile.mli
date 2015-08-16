open Core.Std

type message =
  { player : Uuid.t
  ; time   : Time.t
  ; text   : string
  } with sexp, compare

type t with sexp, compare

val create :
  resources:Resources.t
  -> players:Uuid.t list
  -> messages:message list
  -> t

val from :
  ?resources:Resources.t
  -> ?players:Uuid.t list
  -> ?messages:message list
  -> t
  -> t

val empty : t

val with_resources : t -> Resources.t -> t

val resources : t -> Resources.t
val players : t -> Uuid.t list
val messages : t -> message list
