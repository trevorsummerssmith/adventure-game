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
    let trees = Tile.trees tile + 1 in
    Board.set board (Tile.from ~trees tile) op.posn
  | Remove_tree ->
    let trees = if (Tile.trees tile) = 0 then 0
      else (Tile.trees tile) - 1 in
    Board.set board (Tile.from ~trees tile) op.posn
  | Add_rock ->
    let rocks = (Tile.rocks tile) + 1 in
    Board.set board (Tile.from ~rocks tile) op.posn
  | Remove_rock ->
    let rocks = if (Tile.rocks tile) = 0 then 0
      else (Tile.rocks tile) - 1 in
    Board.set board (Tile.from ~rocks tile) op.posn

let step dynamo =
  if dynamo.tick >= Game.num_ops dynamo.game then
    ()
  else
    let op = Game.nth_op dynamo.game dynamo.tick in
    let () = take_action dynamo.board op in
    dynamo.tick <- (dynamo.tick + 1)

let run dynamo =
  for i = 0 to Game.num_ops dynamo.game do
    step dynamo
  done

let get_tile dynamo posn =
  Board.get dynamo.board posn
