open Core.Std

type code =
  | Add_player of string * Uuid.t option
  (* Player name
     This op will create a new id for the player to be used in
     all subsequent player ops *)
  | Move_player of Uuid.t
  | Player_message of Uuid.t * Time.t * string
  (* Player id, time message occurred in utc, message *)
  | Player_harvest of Uuid.t * Resources.kind
  (* Player id, kind of resource to harvest *)
  | Add_resource of Resources.kind
  | Remove_resource of Resources.kind with sexp

type t =
  { posn : Posn.t
  ; code : code
  ; time : Time.t (* Server time this op was created *)
  } with sexp

let create ?time code posn =
  { code
  ; posn
  ; time = Option.value ~default:(Time.now()) time
  }
