open Core.Std

module Id = Uuid

module Prop = Univ_map.Key

type t = Univ_map.t with sexp_of

val create : ?id:Id.t -> unit -> t

val id : t -> Id.t
