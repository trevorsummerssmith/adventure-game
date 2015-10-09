open Core.Std

(**
   We should be thoughtful about what goes into a code. We want to have
   the minimal information necessary for the operation to occur.

   Prefer using non-aggregate types that are the constituent parts
   necessary. For example, for the player create message op, we use
   the player's id (uuid), the time the message occurred and the message
   text. We could have used the player type and a message type.

   By keeping this separate we decouple the implementation of these types
   (which we expect to change and get more complex with time), and the
   ops that mutate this state itself.
*)

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
  | Player_create_artifact of Uuid.t * string * Uuid.t option * Uuid.t option
  (* Player id
     artifact text
     optional id of the buildable
     optional id of the artifact *)
  | Buildable_update of Uuid.t * Atoms.percent_complete
  (* Buildable id, status of the entity update *)
  | Add_resource of Resources.kind
  | Remove_resource of Resources.kind with sexp, compare

type t =
  { posn : Posn.t
  ; code : code
  ; time : Time.t (* Server time this op was created *)
  } with sexp, compare

let create ?time code posn =
  { code
  ; posn
  ; time = Option.value ~default:(Time.now()) time
  }
