open Core.Std

type t = (Uuid.t, Univ_map.t) Hashtbl.t

let create () =
  Uuid.Table.create ()

let get tbl id =
  Hashtbl.find tbl id

let get_exn tbl id =
  Hashtbl.find_exn tbl id

let add_exn tbl id =
  Hashtbl.add_exn tbl ~key:id ~data:Univ_map.empty

let replace tbl id entity =
  Hashtbl.replace tbl ~key:id ~data:entity

module Prop = Univ_map.Key

let get_prop_exn tbl id prop =
  let map = Hashtbl.find_exn tbl id in
  Univ_map.find_exn map prop

let set_prop tbl id prop value =
  let map = Hashtbl.find_exn tbl id in
  let map = Univ_map.set map prop value in
  Hashtbl.replace tbl ~key:id ~data:map

let incr_prop tbl id prop =
  let map = Hashtbl.find_exn tbl id in
  let map = Univ_map.change map prop
      (function
        | None -> Some 1
        | Some n -> Some (n + 1))
  in
  Hashtbl.replace tbl ~key:id ~data:map

let decr_prop tbl id prop =
  let map = Hashtbl.find_exn tbl id in
  let map = Univ_map.change map prop
      (function
        | None -> Some (-1)
        | Some n -> Some (n - 1))
  in
  Hashtbl.replace tbl ~key:id ~data:map
