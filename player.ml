open Core.Std

type t =
  { name      : string
  ; posn      : Posn.t
  ; id        : Uuid.t
  ; resources : Resources.t
  } with sexp, compare

let create ?id ~resources ~name ~posn =
  { name
  ; posn
  ; id = Option.value ~default:(Uuid.create ()) id
  ; resources
  }

let with_resources p resources =
  {p with resources}

let move p posn =
  {p with posn}

let name p = p.name

let posn p = p.posn

let id p = p.id

let resources p = p.resources
