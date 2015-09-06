open Core.Std

type artifact =
  { id : Uuid.t
  ; player_id : Uuid.t
  ; text      : string
  } with sexp, compare

module Buildable = struct
  type status =
    | Building of int
    (** 0...99 inclusive. *)
    | Complete with sexp, compare

  type t =
    { entity : artifact
    ; percent_complete : status
    } with sexp, compare
end
