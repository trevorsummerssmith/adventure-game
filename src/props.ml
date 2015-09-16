open Core.Std

let posn_prop = Entity.Prop.create ~name:"posn" Posn.sexp_of_t

let posn es id =
  Entity_store.get_prop_exn es id posn_prop

let set_posn es id posn =
  failwith "not implemented"

let get_posn entity =
  failwith "not implemented"

let add_posn entity ~posn =
  failwith "not implemented"

let name es id =
  failwith "not implemented"

let set_name es id name =
  failwith "not implemented"

let get_name entity =
  failwith "not implemented"

let add_name entity ~name =
  failwith "not implemented"

let resources es id =
  failwith "not implemented"

let set_resources es id resources =
  failwith "not implemented"

let get_resources entity =
  failwith "not implemented"

let add_resources entity ~resources =
  failwith "not implemented"

let buildables es id =
  failwith "not implemented"

let set_buildables es id buildables =
  failwith "not implemented"

let add_to_buildables es ~id ~buildable =
  failwith "not implemented"

let remove_from_buildables es ~id ~buildable =
  failwith "not implemented"

let get_buildables entity =
  failwith "not implemented"

let add_buildables entity ~buildables =
  failwith "not implemented"

let artifacts es id =
  failwith "not implemented"

let set_artifacts es id artifacts =
  failwith "not implemented"

let add_to_artifacts es ~id ~artifact =
  failwith "not implemented"

let get_artifacts entity =
  failwith "not implemented"

let add_artifacts entity ~artifacts =
  failwith "not implemented"
