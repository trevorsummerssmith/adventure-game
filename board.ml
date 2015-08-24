open Core.Std

type t =
  { board : Tile.t array array
  ; dimensions : Posn.t
  } with sexp

let create (width, height) =
  let board = Array.make_matrix ~dimx:width ~dimy:height Tile.empty in
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

let mapi board ~(f : int -> int -> Tile.t -> 'a) : 'a array array =
  Array.mapi ~f:(fun (x:int) arr ->
      Array.mapi ~f:(fun (y:int) (tile:Tile.t) -> f x y tile) arr
    )
    board.board
