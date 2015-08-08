open Core.Std

type t =
  { trees : int
  ; rocks : int
  } with sexp, compare

let create ~trees ~rocks =
  { trees
  ; rocks
  }

let from ?trees ?rocks tile =
  { trees = Option.value ~default:tile.trees trees
  ; rocks = Option.value ~default:tile.rocks rocks
  }

let empty_tile = {trees=0;rocks=0}

let trees tile = tile.trees

let rocks tile = tile.rocks
