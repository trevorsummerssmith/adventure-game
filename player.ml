open Core.Std

type t =
  { name : string
  ; posn : Posn.t
  ; id   : Uuid.t
  } with sexp

let create ?id ~name ~posn =
  { name
  ; posn
  ; id = Option.value ~default:(Uuid.create ()) id
  }

let move p posn =
  {p with posn}

let name p = p.name

let posn p = p.posn

let id p = p.id
