open Core.Std

type t (* TODO with sexp *)

val create : unit -> t

(** Entities *)

val get : t -> Entity.Id.t -> Entity.t Option.t

val get_exn : t -> Entity.Id.t -> Entity.t

val add_exn : t -> Entity.Id.t -> unit
(* TODO probably nix this? *)

val replace : t -> Entity.Id.t -> Entity.t -> unit

(** Properties *)

val get_prop_exn : t -> Entity.Id.t -> 'a Entity.Prop.t -> 'a

val set_prop_exn : t -> Entity.Id.t -> 'a Entity.Prop.t -> 'a -> unit
(** Throws if [id] does not exist *)

val incr_prop : t -> Entity.Id.t -> int Entity.Prop.t -> unit
(** [incr_prop es id prop] increments [prop] by 1. If [prop] is not defined
    this will set it to 1.
*)

val decr_prop : t -> Entity.Id.t -> int Entity.Prop.t -> unit
(** [decr_prop es id prop] decrements [prop] by 1. If [prop] is not defined
    this will set it to -1.
*)

val add_to_prop_exn : t -> Entity.Id.t -> 'a list Entity.Prop.t -> 'a -> unit
val remove_from_prop_exn : t -> Entity.Id.t -> 'a list Entity.Prop.t -> 'a -> unit
