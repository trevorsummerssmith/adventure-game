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

(** Players *)
val players : Entity.t -> Entity.Id.t list
val add_players : Entity.t -> players:Entity.Id.t list -> Entity.t
val add_to_players
  : Entity_store.t -> id:Entity.Id.t -> player:Entity.Id.t -> unit
val remove_from_players
  : Entity_store.t -> id:Entity.Id.t -> player:Entity.Id.t -> unit

(** Messages *)
val messages : Entity.t -> Message.t list
val add_messages : Entity.t -> messages:Message.t list -> Entity.t
val get_messages : Entity_store.t -> Entity.Id.t -> Message.t list
val set_messages : Entity_store.t -> Entity.Id.t -> messages:Message.t list -> unit

(** Owner (player id) *)
val owner : Entity.t -> Entity.Id.t
val add_owner : Entity.t -> owner:Entity.Id.t -> Entity.t
val get_owner : Entity_store.t -> Entity.Id.t -> Entity.Id.t
val set_owner : Entity_store.t -> id:Entity.Id.t -> owner:Entity.Id.t -> unit

(** Text (this can be used for variuos purposes) *)
val text : Entity.t -> string
val add_text : Entity.t -> text:string -> Entity.t
val get_text : Entity_store.t -> Entity.Id.t -> string
val set_text : Entity_store.t -> Entity.Id.t -> string -> unit

(** Percent Complete (for building something) *)
val percent_complete : Entity.t -> Atoms.percent_complete
val add_percent_complete
  : Entity.t
  -> percent_complete:Atoms.percent_complete
  -> Entity.t
val get_percent_complete
  : Entity_store.t
  -> Entity.Id.t
  -> Atoms.percent_complete
val set_percent_complete
  : Entity_store.t
  -> id:Entity.Id.t
  -> percent_complete:Atoms.percent_complete
  -> unit

(** Kind (used for building something) *)
val kind : Entity.t -> Atoms.kind
val add_kind : Entity.t -> kind:Atoms.kind -> Entity.t
val get_kind : Entity_store.t -> Entity.Id.t -> Atoms.kind
val set_kind
  : Entity_store.t
  -> id:Entity.Id.t
  -> kind:Atoms.kind
  -> unit

(** locked -- used for a temple *)
val locked : Entity.t -> bool
val add_locked : Entity.t -> locked:bool -> Entity.t
val get_locked : Entity_store.t -> Entity.Id.t -> bool
val set_locked : Entity_store.t -> id:Entity.Id.t -> locked:bool -> unit

(** Entities that can be on a Tile. *)
val extants : Entity.t -> Atoms.extant list
val add_extants : Entity.t -> extants:Atoms.extant list -> Entity.t
val add_to_extants
  : Entity_store.t -> id:Entity.Id.t -> extant:Atoms.extant -> unit
val remove_from_extants
  : Entity_store.t -> id:Entity.Id.t -> extant:Atoms.extant -> unit
