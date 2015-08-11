open Core.Std

type message =
  { player : Uuid.t
  ; time   : Time.t
  ; text   : string
  } with sexp, compare

type t =
  { trees : int
  ; rocks : int
  ; players : Uuid.t list
  ; messages : message list
  (* Head of messages is oldest message *)
  } with sexp, compare

let create ~trees ~rocks ~players ~messages =
  { trees
  ; rocks
  ; players
  ; messages
  }

let from ?trees ?rocks ?players ?messages tile =
  { trees = Option.value ~default:tile.trees trees
  ; rocks = Option.value ~default:tile.rocks rocks
  ; players = Option.value ~default:tile.players players
  ; messages = Option.value ~default:tile.messages messages
  }

let empty =
  { trees=0
  ; rocks=0
  ; players=[]
  ; messages=[]
  }

let trees tile = tile.trees

let rocks tile = tile.rocks

let players tile = tile.players

let messages tile = tile.messages
