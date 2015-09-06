open Core.Std

type t =
  { name      : string
  ; posn      : Posn.t
  ; id        : Uuid.t
  ; resources : Resources.t
  ; buildables : Uuid.t list
  ; artifacts  : Uuid.t list
  } with sexp, compare

let create ?id ?(buildables=[]) ?(artifacts=[]) ~resources ~posn name =
  { name
  ; posn
  ; id = Option.value ~default:(Uuid.create ()) id
  ; resources
  ; buildables
  ; artifacts
  }

let with_buildables p buildables =
  {p with buildables}

let with_resources p resources =
  {p with resources}

let with_artifacts p artifacts =
  {p with artifacts}

let move p posn =
  {p with posn}

let name p = p.name

let posn p = p.posn

let id p = p.id

let resources p = p.resources

let buildables {buildables; _} = buildables

let artifacts {artifacts; _} = artifacts
