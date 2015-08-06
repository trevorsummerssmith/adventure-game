(** Coordinates on the board in the form of (x,y).
    That are compareable and hashable.
    This entire module is really just 'type posn = int * int'.
*)

open Core.Std

module T = struct
  type t = int * int with sexp, compare
  let hash (x,y) =
    (Int.hash x) lxor (Int.hash y) (* TODO XXX make sure this is good *)
end

include T
include Comparable.Make(T)
include Hashable.Make(T)

let nowhere : t = (Int.max_value, Int.max_value)
(** We need initialization and this comes up. *)

let neighbor_deltas : t list =
  [(-1, -1); (0, -1); (1, -1);
   (-1, 0); (1, 0);
   (-1, 1); (0, 1); (1, 1)]
(** Possible relative moves, including not moving.
    A list of length 8 with the following entries:
    -1,-1  0,-1  1,-1
    -1,0  here 1,0
    -1,1  0,1  1,1
*)
