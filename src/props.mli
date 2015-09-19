open Core.Std

(* TODO exn or option? *)

val get_posn : Entity_store.t -> Entity.Id.t -> Posn.t
val set_posn : Entity_store.t -> Entity.Id.t -> Posn.t -> unit

val posn : Entity.t -> Posn.t
val add_posn : Entity.t -> posn:Posn.t -> Entity.t

val get_name : Entity_store.t -> Entity.Id.t -> string
val set_name : Entity_store.t -> Entity.Id.t -> string -> unit

val name : Entity.t -> string
val add_name : Entity.t -> name:string -> Entity.t

val get_resources : Entity_store.t -> Entity.Id.t -> Resources.t
val set_resources : Entity_store.t -> Entity.Id.t -> Resources.t -> unit

val resources : Entity.t -> Resources.t
val add_resources : Entity.t -> resources:Resources.t -> Entity.t

val get_buildables : Entity_store.t -> Entity.Id.t -> Entity.Id.t list
val set_buildables : Entity_store.t -> Entity.Id.t -> Entity.Id.t list -> unit
val add_to_buildables : Entity_store.t -> id:Entity.Id.t -> buildable:Entity.Id.t -> unit
val remove_from_buildables : Entity_store.t -> id:Entity.Id.t -> buildable:Entity.Id.t -> unit

val buildables : Entity.t -> Entity.Id.t list
val add_buildables : Entity.t -> buildables:Entity.Id.t list -> Entity.t

val get_artifacts : Entity_store.t -> Entity.Id.t -> Entity.Id.t list
val set_artifacts : Entity_store.t -> Entity.Id.t -> Entity.Id.t list -> unit
val add_to_artifacts : Entity_store.t -> id:Entity.Id.t -> artifact:Entity.Id.t -> unit

val artifacts : Entity.t -> Entity.Id.t list
val add_artifacts : Entity.t -> artifacts:Entity.Id.t list -> Entity.t
