open Core.Std

type t =
  { ops : Game_op.t list
  ; board_dimensions : Posn.t
  } with sexp

let create ops board_dimensions =
  { ops
  ; board_dimensions
  }

let board_dimensions game =
  game.board_dimensions

let num_ops game =
  List.length game.ops

let add_op game op =
  (* We add to the tail so our indices don't change *)
  assert (let last_op = List.nth_exn game.ops (List.length game.ops - 1) in
          Time.compare op.Game_op.time last_op.Game_op.time >= 0);
  let ops = game.ops @ [op] in
  {game with ops}

let nth_op game i =
  List.nth_exn game.ops i
