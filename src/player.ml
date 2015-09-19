open Core.Std

type t = Entity.t with sexp_of

let compare (a : t) (b : t) = compare a b

let create ?id ?(buildables=[]) ?(artifacts=[]) ~resources ~posn name =
  Entity.create ?id ()
  |> Props.add_posn ~posn
  |> Props.add_name ~name
  |> Props.add_buildables ~buildables
  |> Props.add_artifacts ~artifacts
  |> Props.add_resources ~resources
