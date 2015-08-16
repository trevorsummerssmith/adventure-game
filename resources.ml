open Core.Std

(*
   Invariant: the map always has all of its keys, so that we don't have to
   worry comparison and equal being weird with eg "Wood, 0" and no entry for
   Wood being equal or not.
*)

type kind =
  | Wood
  | Rock with sexp, compare

type t = (kind, int) Map.Poly.t with sexp, compare

let empty = Map.Poly.of_alist_exn [Wood, 0; Rock, 0]

let of_alist_exn ls =
  (* See note at top of module. Keep evertyhing from right *)
  let right = Map.Poly.of_alist_exn ls in
  Map.Poly.merge
    ~f:(fun ~key v -> match v with
        | `Left x -> Some x
        | `Right x -> Some x
        | `Both (x1,x2) -> Some x2)
    empty
    right

let incr r ~kind =
  Map.change r kind (function None -> Some 1 | Some i -> Some (i+1))

let decr r ~kind =
  Map.change r kind (function None -> Some (-1) | Some i -> Some (i-1))

let get r ~kind =
  Map.find r kind |> Option.value ~default:0
