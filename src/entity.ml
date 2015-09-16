open Core.Std

module Id = Uuid

module Prop = Univ_map.Key

type t = Univ_map.t with sexp_of

let id_prop = Prop.create ~name:"id" Id.sexp_of_t

let create ?id () =
  let id = Option.value ~default:(Id.create ()) id in
  Univ_map.add_exn Univ_map.empty id_prop id

let id entity =
  Univ_map.find_exn entity id_prop
