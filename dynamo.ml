open Core.Std

(*
   Player location data is denormalized and represented in both the board
   and the player. Invariant: the player location and board location of a player
   should always be the same.
*)

type t =
  { mutable game : Game.t
  ; board : Board.t
  ; players : (Uuid.t, Player.t) Hashtbl.t
  (* Mapping from player id to players. The id should only come from the player
     entity itself. *)
  ; mutable tick : int
  (* Time in the game.
     This starts at 0 and is an index into the game ops. It represents
     the the next instruction to be ran. The board represents op tick-1.
  *)
  }

let create game =
  { game
  ; board = Game.board_dimensions game |> Board.create
  ; players = Uuid.Table.create ()
  ; tick = 0
  }

let take_action dynamo op =
  (* Applies the action to the board *)
  let open Game_op in
  let board = dynamo.board in
  let tile = Board.get board op.posn in
  match op.op with
  | Add_player (name, id_op) ->
    (* 1) Generate new id for player 2) add to player structure 3) add to board *)
    let player = Player.create ?id:id_op ~name ~posn:op.posn in
    let id = Player.id player in
    let () = Hashtbl.add_exn dynamo.players ~key:(Player.id player) ~data:player in
    let tile = Board.get board op.posn in
    let players = id :: (Tile.players tile) in
    Board.set board (Tile.from ~players tile) op.posn
  | Move_player id ->
    (* 1. Find player's current position and remove it *)
    let player = Hashtbl.find_exn dynamo.players id in
    let cur_posn = Player.posn player in
    let tile = Board.get board cur_posn in
    let players = List.filter ~f:(fun a -> a <> id) (Tile.players tile) in
    let () = Board.set board (Tile.from ~players tile) cur_posn in
    (* 2. Update new tile *)
    let tile = Board.get board op.posn in
    let players = id :: (Tile.players tile) in
    let () = Board.set board (Tile.from ~players tile) op.posn in
    (* 3. Update player position *)
    let player = Player.move player op.posn in
    Hashtbl.replace dynamo.players ~key:id ~data:player
  | Player_message (id, time, text) ->
    (* Update tile with message. Re-sort to make sure its in time order *)
    let msg = Tile.({player=id;time;text}) in
    let tile = Board.get board op.posn in
    let messages = msg :: (Tile.messages tile)
                   |> List.sort ~cmp:(fun a b -> (Time.compare a.Tile.time b.Tile.time)) in
    let tile = Tile.from ~messages tile in
    Board.set board tile op.posn
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
    let () = take_action dynamo op in
    dynamo.tick <- (dynamo.tick + 1)

let run dynamo =
  for i = 0 to Game.num_ops dynamo.game do
    step dynamo
  done

let validate_player_message dynamo (id, time, text) posn : unit Or_error.t =
  (* 1) Player must exist
     2) Player must be on the same tile as where the talking is taking place
     N.B. we're not doing any checks on the time right now
  *)
  match Hashtbl.find dynamo.players id with
  | None -> Or_error.error_string "Player not found"
  | Some p ->
    if (Player.posn p) = posn then
      Ok ()
    else
      Or_error.error_string "Player not on right position."

let add_op dynamo op =
  let open Or_error.Monad_infix in
  let open Game_op in
  let resp = match op.op with
    | Player_message (id, time, text) ->
      validate_player_message dynamo (id, time, text) op.posn
    | _ -> Ok ()
  in
  resp >>| fun () ->
  let game = Game.add_op dynamo.game op in
  dynamo.game <- game

let get_tile dynamo posn =
  Board.get dynamo.board posn

let players dynamo =
  dynamo.players

let dimensions dynamo =
  Board.dimensions dynamo.board

let game dynamo =
  dynamo.game
