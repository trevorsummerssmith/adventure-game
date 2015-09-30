open Core.Std

type t = Entity.t with sexp_of

let shallow_compare (a : t) (b : t) =
  let resources = Props.resources a in
  let resources' = Props.resources b in
  let players = Props.players a in
  let players' = Props.players b in
  let messages = Props.messages a in
  let messages' = Props.messages b in
  List.fold
    ~init:0
    ~f:(+)
    [Resources.compare resources resources'
    ;compare players players'
    ;compare messages messages']

let create ?id ~resources ~players ~messages () =
  Entity.create ?id ()
  |> Props.add_resources ~resources
  |> Props.add_players ~players
  |> Props.add_messages ~messages

let empty =
  Entity.create ()
  |> Props.add_resources ~resources:Resources.empty
  |> Props.add_players ~players:[]
  |> Props.add_messages ~messages:[]
