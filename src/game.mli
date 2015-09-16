(** Immutable game *)

type t with sexp

val create : Game_op.t list -> Posn.t -> t

val board_dimensions : t -> Posn.t

val num_ops : t -> int

val add_op : t -> Game_op.t -> t
(** [add_op game op]
    Invariant: op times are monotonically increasing.
*)

val nth_op : t -> int -> Game_op.t
(** Raises an exception if [nth] is out of bounds *)
