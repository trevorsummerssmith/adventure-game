open Core.Std

type t =
  { trees : int
  ; rocks : int
  ; players : Uuid.t list
  } with sexp, compare

let create ~trees ~rocks ~players =
  { trees
  ; rocks
  ; players
  }

let from ?trees ?rocks ?players tile =
  { trees = Option.value ~default:tile.trees trees
  ; rocks = Option.value ~default:tile.rocks rocks
  ; players = Option.value ~default:tile.players players
  }

let empty_tile =
  { trees=0
  ; rocks=0
  ; players=[]
  }

let trees tile = tile.trees

let rocks tile = tile.rocks

let players tile = tile.players
