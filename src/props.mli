open Core.Std

(* TODO exn or option? *)

val posn : Entity_store.t -> Entity.Id.t -> Posn.t
val set_posn : Entity_store.t -> Entity.Id.t -> Posn.t -> unit

val get_posn : Entity.t -> Posn.t
val add_posn : Entity.t -> posn:Posn.t -> Entity.t

val name : Entity_store.t -> Entity.Id.t -> string
val set_name : Entity_store.t -> Entity.Id.t -> string -> unit

val get_name : Entity.t -> string
val add_name : Entity.t -> name:string -> Entity.t

val resources : Entity_store.t -> Entity.Id.t -> Resources.t
val set_resources : Entity_store.t -> Entity.Id.t -> Resources.t -> unit

val get_resources : Entity.t -> Resources.t
val add_resources : Entity.t -> resources:Resources.t -> Entity.t

val buildables : Entity_store.t -> Entity.Id.t -> Entity.Id.t list
val set_buildables : Entity_store.t -> Entity.Id.t -> Entity.Id.t list -> unit
val add_to_buildables : Entity_store.t -> id:Entity.Id.t -> buildable:Entity.Id.t -> unit
val remove_from_buildables : Entity_store.t -> id:Entity.Id.t -> buildable:Entity.Id.t -> unit

val get_buildables : Entity.t -> Entity.Id.t list
val add_buildables : Entity.t -> buildables:Entity.Id.t list -> Entity.t

val artifacts : Entity_store.t -> Entity.Id.t -> Entity.Id.t list
val set_artifacts : Entity_store.t -> Entity.Id.t -> Entity.Id.t list -> unit
val add_to_artifacts : Entity_store.t -> id:Entity.Id.t -> artifact:Entity.Id.t -> unit

val get_artifacts : Entity.t -> Entity.Id.t list
val add_artifacts : Entity.t -> artifacts:Entity.Id.t list -> Entity.t
