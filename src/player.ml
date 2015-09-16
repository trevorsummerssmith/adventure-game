open Core.Std

type t = Entity.t with sexp_of

    (* { name      : string
  ; posn      : Posn.t
  ; id        : Uuid.t
  ; resources : Resources.t
  ; buildables : Uuid.t list
  ; artifacts  : Uuid.t list
      } with sexp, compare*)

let compare (a : t) (b : t) = compare a b

let create ?id ?(buildables=[]) ?(artifacts=[]) ~resources ~posn name =
  Entity.create ?id ()
  |> Props.add_posn ~posn
  |> Props.add_name ~name
  |> Props.add_buildables ~buildables
  |> Props.add_artifacts ~artifacts

  (*  { name
  ; posn
  ; id = Option.value ~default:(Uuid.create ()) id
  ; resources
  ; buildables
  ; artifacts
    }*)

let with_buildables p buildables =
  Props.add_buildables p ~buildables

let with_resources p resources =
  Props.add_resources p ~resources

let with_artifacts p artifacts =
  Props.add_artifacts p ~artifacts

let move p posn =
  Props.add_posn p ~posn

let name p = Props.get_name p

let posn p = Props.get_posn p

let id p = Entity.id p

let resources p = Props.get_resources p

let buildables p = Props.get_buildables p

let artifacts p = Props.get_artifacts p
