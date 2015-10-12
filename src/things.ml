open Core.Std

module Artifact = struct
  type t = Entity.t with sexp_of

  let create ?id ~player_id ~text () =
    Entity.create ?id ()
    |> Props.add_owner ~owner:player_id
    |> Props.add_text ~text
end

module Buildable = struct

  type t = Entity.t with sexp_of

  let create ?id ~percent_complete ~kind () =
    Entity.create ?id ()
    |> Props.add_percent_complete ~percent_complete
    |> Props.add_kind ~kind
end

module Temple = struct

  type t = Entity.t with sexp_of

  let create ?id ~name ~text ~posn ~locked () =
    Entity.create ?id ()
    |> Props.add_name ~name
    |> Props.add_text ~text
    |> Props.add_posn ~posn
    |> Props.add_locked ~locked

end
