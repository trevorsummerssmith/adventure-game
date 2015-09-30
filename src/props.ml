open Core.Std

module E = Entity_store
module U = Univ_map

let create_prop name sexp_of =
  Entity.Prop.create ~name sexp_of

let posn_prop = create_prop "posn" Posn.sexp_of_t
let name_prop = create_prop "name" String.sexp_of_t
let resources_prop = create_prop "resources" Resources.sexp_of_t
let buildables_prop = create_prop "buildables" <:sexp_of<Uuid.t list>>
let artifacts_prop = create_prop "artifacts" <:sexp_of<Uuid.t list>>
let players_prop = create_prop "players" <:sexp_of<Uuid.t list>>
let messages_prop = create_prop "messages" <:sexp_of<Message.t list>>

let get_posn es id =
  E.get_prop_exn es id posn_prop

let set_posn es id posn =
  E.set_prop_exn es id posn_prop posn

let posn entity =
  U.find_exn entity posn_prop

let add_posn entity ~posn =
  U.add_exn entity posn_prop posn

let get_name es id =
  E.get_prop_exn es id name_prop

let set_name es id name =
  E.set_prop_exn es id name_prop name

let name entity =
  U.find_exn entity name_prop

let add_name entity ~name =
  U.add_exn entity name_prop name

let get_resources es id =
  E.get_prop_exn es id resources_prop

let set_resources es id resources =
  E.set_prop_exn es id resources_prop resources

let resources entity =
  U.find_exn entity resources_prop

let add_resources entity ~resources =
  U.add_exn entity resources_prop resources

let get_buildables es id =
  E.get_prop_exn es id buildables_prop

let set_buildables es id buildables =
  E.set_prop_exn es id buildables_prop buildables

let add_to_buildables es ~id ~buildable =
  E.add_to_prop_exn es id buildables_prop buildable

let remove_from_buildables es ~id ~buildable =
  E.remove_from_prop_exn es id buildables_prop buildable

let buildables entity =
  U.find_exn entity buildables_prop

let add_buildables entity ~buildables =
  U.add_exn entity buildables_prop buildables

let get_artifacts es id =
  E.get_prop_exn es id artifacts_prop

let set_artifacts es id artifacts =
  E.set_prop_exn es id artifacts_prop artifacts

let add_to_artifacts es ~id ~artifact =
  E.add_to_prop_exn es id artifacts_prop artifact

let artifacts entity =
  U.find_exn entity artifacts_prop

let add_artifacts entity ~artifacts =
  U.add_exn entity artifacts_prop artifacts

let players entity =
  U.find_exn entity players_prop

let add_players entity ~players =
  U.add_exn entity players_prop players

let add_to_players es ~id ~player =
  E.add_to_prop_exn es id players_prop player

let remove_from_players es ~id ~player =
  E.remove_from_prop_exn es id players_prop player

let messages entity =
  U.find_exn entity messages_prop

let add_messages entity ~messages =
  U.add_exn entity messages_prop messages

let get_messages es id =
  E.get_prop_exn es id messages_prop

let set_messages es id ~messages =
  E.set_prop_exn es id messages_prop messages
