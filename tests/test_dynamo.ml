open Core.Std
open Async.Std
open OUnit2
open Test_helpers

let empty_apply _ =
  let game = Game.create [] (1,1) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  ae_tile Tile.empty (Dynamo.get_tile dynamo (0,0))

let add_one_player _ =
  (* Insure
     1) dynamo player structure is correct
     2) player entity is correct
     3) board is correct
  *)
  let ops = [Game_op.(create (Add_player ("Purple Player", None)) (2,2))] in
  let dynamo = run_with_ops ops in
  let players = Dynamo.players dynamo in
  assert_equal 1 (List.length players);
  let id = List.hd_exn players in
  assert_equal "Purple Player" (Props.get_name (Dynamo.store dynamo) id);
  assert_equal (2,2) (Props.get_posn (Dynamo.store dynamo) id);
  ae_tile (Tile.from ~players:[id] Tile.empty) (Dynamo.get_tile dynamo (2,2))

let add_three_players_two_to_same_tile _ =
  (* lets make sure that adding a few players keeps the right state *)
  let open Game_op in
  let ops = [create (Add_player ("Purple Player", None)) (2,2);
             create (Add_player ("Red Player", None)) (2,2);
             create (Add_player ("Blue Player", None)) (3,5);
            ] in
  let dynamo = run_with_ops ops in
  let players = Dynamo.players dynamo in
  assert_equal 3 (List.length players);
  let players_sorted = List.map ~f:(fun id ->
      let player = Entity_store.get_exn (Dynamo.store dynamo) id in
      Props.name player, Props.posn player) players
                       |> List.sort ~cmp:(fun (n1,_) (n2,_) -> String.compare n1 n2)
  in
  assert_equal ~printer:(fun ls ->
      List.map ~f:(fun (name, (x,y)) -> sprintf "%s (%d,%d)" name x y) ls
      |> String.concat ~sep:",")
    ["Blue Player", (3,5);
     "Purple Player", (2,2);
     "Red Player", (2,2)] players_sorted;
  (* Check board *)
  assert_players_on_board dynamo

let move_one_player _ =
  let open Game_op in
  let id = Uuid.create () in
  let ops = [create (Add_player ("Purple Player", Some id)) (2,2);
             create (Move_player id) (3,3);
            ] in
  let dynamo = run_with_ops ops in
  assert_equal (3,3) (Props.get_posn (Dynamo.store dynamo) id);
  ae_tile Tile.empty (Dynamo.get_tile dynamo (2,2));
  ae_tile (Tile.from ~players:[id] Tile.empty) (Dynamo.get_tile dynamo (3,3))

let run_player_message _ =
  let open Game_op in
  let id = Uuid.create () in
  let time = Time.now () in
  let text = "Great message!" in
  let ops = [create (Add_player ("Awesome Andy", Some id)) (2,3);

            ] in
  let dynamo = run_with_ops ops in
  let _ = Dynamo.add_op dynamo (create (Player_message (id, time, text)) (2,3)) in
  let () = Dynamo.step dynamo  in
  let tile = Dynamo.get_tile dynamo (2,3) in
  let correct_tile = Tile.(from ~players:[id]
                             ~messages:[{player=id;time;text}]
                             empty) in
  ae_tile correct_tile tile

let run_player_message_good _ =
  let open Game_op in
  let id = Uuid.create () in
  let time = Time.now () in
  let text = "Great message!" in
  let ops = [create (Add_player ("Awesome Andy", Some id)) (2,3);
             create (Player_message (id, time, text)) (2,3);
            ] in
  let dynamo = run_with_ops ops in
  let tile = Dynamo.get_tile dynamo (2,3) in
  let correct_tile = Tile.(from ~players:[id]
                             ~messages:[{player=id;time;text}]
                             empty) in
  ae_tile correct_tile tile

let add_player_message_valid _ =
  let open Game_op in
  let id = Uuid.create () in
  let time = Time.now () in
  let text = "Great message!" in
  let ops = [create (Add_player ("Awesome Andy", Some id)) (2,3)] in
  let dynamo = run_with_ops ops in
  let op = create (Player_message (id, time, text)) (2,3) in
  let resp = Dynamo.add_op dynamo op in
  assert_equal (Ok ()) resp

let add_player_message_invalid_player _ =
  let open Game_op in
  let id = Uuid.create () in
  let time = Time.now () in
  let text = "Great message!" in
  let dynamo = run_with_ops [] in
  let op = create (Player_message (id, time, text)) (2,3) in
  let resp = Dynamo.add_op dynamo op in
  match resp with
  | Ok () -> failwith "Error expected failure"
  | Error s -> ()

let add_player_message_invalid_position _ =
  let open Game_op in
  let id = Uuid.create () in
  let time = Time.now () in
  let text = "Great message!" in
  let ops = [create (Add_player ("Awesome Andy", Some id)) (2,3)] in
  let dynamo = run_with_ops ops in
  let op = create (Player_message (id, time, text)) (5,4) in
  let resp = Dynamo.add_op dynamo op in
  match resp with
  | Ok () -> failwith "Error expected failure"
  | Error s -> ()

let add_and_run_player_harvest_wood_success _ =
  let open Game_op in
  let id = Uuid.create () in
  let ops = [create (Add_player ("Awesome Andy", Some id)) (2,3);
             create (Add_resource Resources.Wood) (2,3);
             create (Add_resource Resources.Wood) (2,3);
             create (Add_resource Resources.Rock) (2,3);
             create (Add_resource Resources.Rock) (2,3);] in
  let dynamo = run_with_ops ops in
  create (Player_harvest (id, Resources.Wood)) (2,3)
  |> Dynamo.add_op dynamo
  |> assert_equal Result.ok_unit;
  Dynamo.step dynamo;
  assert_equal 1 (Props.get_resources (Dynamo.store dynamo) id
                  |> Resources.get ~kind:Resources.Wood);
  ae_tile (make_tile ~players:[id] Resources.([Wood, 1; Rock, 2])) (Dynamo.get_tile dynamo (2,3))

let add_player_harvest_failure_no_resource _ =
  let open Game_op in
  let id = Uuid.create () in
  let ops = [create (Add_player ("Awesome Andy", Some id)) (2,3);] in
  let dynamo = run_with_ops ops in
  let op = create (Player_harvest (id, Resources.Wood)) (2,3) in
  let resp = Dynamo.add_op dynamo op in
  match resp with
  | Ok () -> failwith "Expected failure"
  | Error s -> ();
    assert_equal 1 (Dynamo.game dynamo |> Game.num_ops)

let add_tree _ =
  let dynamo = run_with_ops
      [Game_op.(create (Add_resource Resources.Wood) (1,2))] in
  ae_tile (make_tile [Resources.Wood,1]) (Dynamo.get_tile dynamo (1,2))

let add_rock _ =
  let dynamo = run_with_ops
      [Game_op.(create (Add_resource Resources.Rock) (1,2))] in
  ae_tile (make_tile [Resources.Rock,1]) (Dynamo.get_tile dynamo (1,2))

let add_rock_and_tree_same_tile _ =
  let dynamo = run_with_ops Game_op.([
      create (Add_resource Resources.Rock) (1,2)
    ; create (Add_resource Resources.Wood) (1,2)]) in
  ae_tile (make_tile [Resources.Rock,1; Resources.Wood,1])
    (Dynamo.get_tile dynamo (1,2))

let add_rock_and_tree_different_tiles _ =
  let dynamo = run_with_ops Game_op.([
      create (Add_resource Resources.Rock) (2,3)
    ; create (Add_resource Resources.Wood) (1,2)]) in
  ae_tile (make_tile [Resources.Rock,1]) (Dynamo.get_tile dynamo (2,3));
  ae_tile (make_tile [Resources.Wood,1]) (Dynamo.get_tile dynamo (1,2))

let multiple_adds _ =
  let ops = Game_op.([ create (Add_resource Resources.Rock) (2,3)
                     ; create (Add_resource Resources.Rock) (2,3)
                     ; create (Add_resource Resources.Wood) (2,3)
                     ; create (Add_resource Resources.Wood) (1,2)
                     ; create (Add_resource Resources.Rock) (5,5)
                     ; create (Add_resource Resources.Rock) (5,5)
                     ; create (Add_resource Resources.Rock) (5,5)
                     ]) in
  let dynamo = run_with_ops ops in
  ae_tile (make_tile Resources.([Wood, 1; Rock, 2]))
    (Dynamo.get_tile dynamo (2,3));
  ae_tile (make_tile [Resources.Wood, 1]) (Dynamo.get_tile dynamo (1,2));
  ae_tile (make_tile [Resources.Rock, 3]) (Dynamo.get_tile dynamo (5,5))

let remove_tree _ =
  let ops = Game_op.([ create (Add_resource Resources.Rock) (1,2)
                     ; create (Add_resource Resources.Wood) (1,2)
                     ; create (Remove_resource Resources.Wood) (1,2)
                     ]) in
  let dynamo = run_with_ops ops in
  ae_tile (make_tile [Resources.Rock, 1]) (Dynamo.get_tile dynamo (1,2))

let remove_rock _ =
  let ops = Game_op.([ create (Add_resource Resources.Rock) (1,2)
                     ; create (Add_resource Resources.Wood) (1,2)
                     ; create (Remove_resource Resources.Rock) (1,2)
                     ]) in
  let dynamo = run_with_ops ops in
  ae_tile (make_tile [Resources.Wood, 1]) (Dynamo.get_tile dynamo (1,2))

let illegal_remove_tree _ =
  let ops = Game_op.([ create (Remove_resource Resources.Wood) (1,2) ]) in
  let dynamo = run_with_ops ops in
  ae_tile (make_tile [Resources.Wood, -1]) (Dynamo.get_tile dynamo (1,2))

let create_artifact_success _ =
  (* Tests that a resource was added to the buildable.
     We're not going to test the async buildable updating that is also launched
     Not sure how to dependency inject all of that without it being really a pain.
     Instead, we test that functionality separately
  *)
  let artifact_id = Uuid.create () in
  let player_id = Uuid.create () in
  let text = "Awesome Artifact" in
  let ops = Game_op.([ create (Add_resource Resources.Rock) (2,3)
                     ; create (Add_resource Resources.Wood) (2,3)
                     ; create (Add_player ("Awesome Andy", Some player_id)) (2,3)
                     ; create (Player_harvest (player_id, Resources.Wood)) (2,3)
                     ; create (Player_harvest (player_id, Resources.Rock)) (2,3)
                     ]) in
  let dynamo = run_with_ops ops in
  let op = Game_op.(create (Player_create_artifact (player_id, text, Some artifact_id))
                      (2,3)) in
  match Dynamo.add_op dynamo op with
  | Result.Error e -> failwith (Error.to_string_hum e)
  | Result.Ok () ->
    Dynamo.step dynamo;
    let buildables = Dynamo.buildables dynamo
                     |> Hashtbl.to_alist in
    let entity = Things.({id=artifact_id; player_id; text}) in
    let answer = Things.Buildable.({percent_complete=Building 0; entity}) in
    assert_equal buildables [artifact_id, answer]

let create_artifact_validation_failure_wood _ =
  (* Player doesn't have enough wood *)
  let artifact_id = Uuid.create () in
  let player_id = Uuid.create () in
  let text = "Awesome Artifact" in
  let ops = Game_op.([ create (Add_resource Resources.Rock) (2,3)
                     ; create (Add_resource Resources.Wood) (2,3)
                     ; create (Add_player ("Awesome Andy", Some player_id)) (2,3)
                     ; create (Player_harvest (player_id, Resources.Rock)) (2,3)
                     ]) in
  let dynamo = run_with_ops ops in
  let op = Game_op.(create (Player_create_artifact (player_id, text, Some artifact_id))
                      (2,3)) in
  match Dynamo.add_op dynamo op with
  | Result.Error e -> ()
  | Result.Ok () -> failwith "Should have a validation error"

let create_artifact_validation_failure_rock _ =
  (* Player doesn't have enough rock *)
  let artifact_id = Uuid.create () in
  let player_id = Uuid.create () in
  let text = "Awesome Artifact" in
  let ops = Game_op.([ create (Add_resource Resources.Rock) (2,3)
                     ; create (Add_resource Resources.Wood) (2,3)
                     ; create (Add_player ("Awesome Andy", Some player_id)) (2,3)
                     ; create (Player_harvest (player_id, Resources.Wood)) (2,3)
                     ]) in
  let dynamo = run_with_ops ops in
  let op = Game_op.(create (Player_create_artifact (player_id, text, Some artifact_id))
                      (2,3)) in
  match Dynamo.add_op dynamo op with
  | Result.Error e -> ()
  | Result.Ok () -> failwith "Should have a validation error"

let buildable_update_percent _ =
  let artifact_id = Uuid.create () in
  let player_id = Uuid.create () in
  let text = "Awesome Artifact" in
  let ops = Game_op.([ create (Add_resource Resources.Rock) (2,3)
                     ; create (Add_resource Resources.Wood) (2,3)
                     ; create (Add_player ("Awesome Andy", Some player_id)) (2,3)
                     ; create (Player_harvest (player_id, Resources.Rock)) (2,3)
                     ; create (Player_harvest (player_id, Resources.Wood)) (2,3)
                     ; create (Player_create_artifact
                                 (player_id, text, Some artifact_id)) (2,3)
                     ]) in
  let dynamo = run_with_ops ops in
  let op = Game_op.(create (Buildable_update (artifact_id, Things.Buildable.Building 35)) (2,3)) in
  match Dynamo.add_op dynamo op with
  | Result.Error e -> failwith "Error"
  | Result.Ok () ->
    Dynamo.step dynamo;
    (* Assert player and game state are updated *)
    let player = Entity_store.get_exn (Dynamo.store dynamo) player_id in
    let buildable = Hashtbl.find_exn (Dynamo.buildables dynamo) artifact_id in
    let artifact = Things.({id=artifact_id; player_id; text}) in
    assert_equal (Things.Buildable.({percent_complete=(Building 35); entity=artifact})) buildable;
    ae_uuid_list [artifact_id] (Props.buildables player);
    ae_uuid_list [] (Props.artifacts player)

let buildable_update_complete _ =
  let artifact_id = Uuid.create () in
  let player_id = Uuid.create () in
  let text = "Awesome Artifact" in
  let ops = Game_op.([ create (Add_resource Resources.Rock) (2,3)
                     ; create (Add_resource Resources.Wood) (2,3)
                     ; create (Add_player ("Awesome Andy", Some player_id)) (2,3)
                     ; create (Player_harvest (player_id, Resources.Rock)) (2,3)
                     ; create (Player_harvest (player_id, Resources.Wood)) (2,3)
                     ; create (Player_create_artifact
                                 (player_id, text, Some artifact_id)) (2,3)
                     ]) in
  let dynamo = run_with_ops ops in
  let op = Game_op.(create (Buildable_update (artifact_id, Things.Buildable.Complete)) (2,3)) in
  match Dynamo.add_op dynamo op with
  | Result.Error e -> failwith "Error"
  | Result.Ok () ->
    Dynamo.step dynamo;
    (* Assert player and game state are updated *)
    let player = Entity_store.get_exn (Dynamo.store dynamo) player_id in
    let artifact = Things.({id=artifact_id; player_id; text}) in
    assert_equal artifact (Hashtbl.find_exn (Dynamo.artifacts dynamo) artifact_id);
    ae_uuid_list [] (Props.buildables player);
    ae_uuid_list [artifact_id] (Props.artifacts player)

let suite =
  "dynamo suite">:::
  [ "empty apply">::empty_apply
  ; "add one player">::add_one_player
  ; "add three players two same tile">::add_three_players_two_to_same_tile
  ; "move one player">::move_one_player
  ; "run player message">::run_player_message
  ; "add player message valid">::add_player_message_valid
  ; "add player message invalid player">::add_player_message_invalid_player
  ; "add player message invalid position">::add_player_message_invalid_position
  ; "add & run player harvest wood success">::add_and_run_player_harvest_wood_success
  ; "add player harvest wood failure no wood">::add_player_harvest_failure_no_resource
  ; "add tree">::add_tree
  ; "add rock">::add_rock
  ; "add rock & tree same">::add_rock_and_tree_same_tile
  ; "add rock & tree different">::add_rock_and_tree_different_tiles
  ; "multiple rocks & trees">::multiple_adds
  ; "remove tree">::remove_tree
  ; "remove rock">::remove_rock
  ; "illegal remove tree">::illegal_remove_tree
  ; "create artifact success">::create_artifact_success
  ; "create artifact validation failure wood">::create_artifact_validation_failure_wood
  ; "create artifact validation failure rock">::create_artifact_validation_failure_rock
  ; "buildable update percent">::buildable_update_percent
  ; "buildable update complete">::buildable_update_complete
  ]
