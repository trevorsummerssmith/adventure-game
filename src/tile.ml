open Core.Std

type message =
  { player : Uuid.t
  ; time   : Time.t
  ; text   : string
  } with sexp, compare

type t =
  { resources : Resources.t
  ; players   : Uuid.t list
  ; messages  : message list
  (* Head of messages is oldest message *)
  } with sexp, compare

let create ~resources ~players ~messages =
  { resources
  ; players
  ; messages
  }

let from ?resources ?players ?messages tile =
  { resources = Option.value ~default:tile.resources resources
  ; players = Option.value ~default:tile.players players
  ; messages = Option.value ~default:tile.messages messages
  }

let empty =
  { resources = Resources.empty
  ; players=[]
  ; messages=[]
  }

let with_resources t resources =
  {t with resources}

let resources tile = tile.resources

let players tile = tile.players

let messages tile = tile.messages
