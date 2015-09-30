open Core.Std

type t =
  { board : Entity.Id.t array array
  ; dimensions : Posn.t
  } with sexp

let create (width, height) =
  let board = Array.init width ~f:(fun _x ->
      Array.init height ~f:(fun _y -> Uuid.create ()))
  in
  {board; dimensions=(width,height)}

let assert_bounds board (x, y) : unit =
  let (w, h) = board.dimensions in
  assert (x < w);
  assert (x >= 0);
  assert (y < h);
  assert (y >= 0)

let get board (x, y) =
  assert_bounds board (x,y);
  board.board.(x).(y)

let set board tile (x, y) =
  assert_bounds board (x,y);
  board.board.(x).(y) <- tile

let dimensions board =
  board.dimensions

let mapi board ~(f : int -> int -> Entity.Id.t -> 'a) : 'a array array =
  Array.mapi ~f:(fun (x:int) arr ->
      Array.mapi ~f:(fun (y:int) (tile:Entity.Id.t) -> f x y tile) arr
    )
    board.board
