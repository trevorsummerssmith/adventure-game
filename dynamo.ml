open Core.Std

type t =
  { game : Game.t
  ; board : Board.t
  ; mutable tick : int
  (* Time in the game.
     This starts at 0 and is an index into the game ops. It represents
     the the next instruction to be ran. The board represents op tick-1.
  *)
  }

let create game =
  { game
  ; board = Game.board_dimensions game |> Board.create
  ; tick = 0
  }

let take_action board op =
  (* Applies the action to the board *)
  let open Game_op in
  let open Tile in (* TODO tmp *)
  let tile = Board.get board op.posn in
  match op.op with
  | Add_tree ->
    let trees = tile.trees + 1 in
    Board.set board {tile with trees} op.posn
  | Remove_tree ->
    let trees = if tile.trees = 0 then 0
      else tile.trees - 1 in
    Board.set board {tile with trees} op.posn
  | Add_rock ->
    let rocks = tile.rocks + 1 in
    Board.set board {tile with rocks} op.posn
  | Remove_rock ->
    let rocks = if tile.rocks = 0 then 0
      else tile.rocks - 1 in
    Board.set board {tile with rocks} op.posn

let step dynamo =
  if dynamo.tick >= Game.num_ops dynamo.game then
    ()
  else
    let op = Game.nth_op dynamo.game dynamo.tick in
    let () = take_action dynamo.board op in
    dynamo.tick <- (dynamo.tick + 1)

let get_tile dynamo posn =
  Board.get dynamo.board posn
