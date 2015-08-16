open Core.Std
open OUnit2

let run_with_ops ?(dimensions=(10,10)) ~ops =
  let dynamo = Game.create ops dimensions |> Dynamo.create in
  let () = Dynamo.run dynamo in
  dynamo

let ae_sexp ?cmp ?pp_diff ?msg sexp a a' =
  assert_equal ?cmp ?pp_diff ?msg
    ~printer:(fun x -> x |> sexp |> Sexp.to_string_hum) a a'

let ae_player p p' =
ae_sexp ~cmp:(fun a b -> (Player.compare a b) = 0) Player.sexp_of_t p p'

let ae_tile t t' =
  ae_sexp ~cmp:(fun a b -> (Tile.compare a b) = 0) Tile.sexp_of_t t t'

let assert_players_on_board dynamo =
  (* Asserts that the list of players in the dynamo have the positions as the
     tiles on the board. N.b. does not do the other way! There could be a player
     on board tile not in the player list and this function would not raise *)
  (* A list of lists where each list is the set of players on the same tile *)
  let players_by_posn =
    Dynamo.players dynamo
    |> Hashtbl.to_alist
    |> List.map ~f:(fun (_,p) -> p)
    |> List.sort ~cmp:(fun p1 p2 -> compare (Player.posn p1) (Player.posn p2))
    |> List.group ~break:(fun p1 p2 -> (Player.posn p1) <> (Player.posn p2))
  in
  List.iter ~f:(fun players ->
      let posn = List.hd_exn players |> Player.posn in
      let tile_player_ids = Dynamo.get_tile dynamo posn |> Tile.players in
      let ids = List.map ~f:Player.id players in
      assert_equal
        (List.sort ~cmp:Uuid.compare tile_player_ids)
        (List.sort ~cmp:Uuid.compare ids)
    ) players_by_posn

let make_tile ?(players=[]) (resources : (Resources.kind,int) List.Assoc.t) =
  let resources = Resources.of_alist_exn resources in
  Tile.from ~players ~resources Tile.empty

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
  let players = Dynamo.players dynamo |> Hashtbl.to_alist in
  assert_equal 1 (List.length players);
  let (id,player) = List.hd_exn players in
  assert_equal "Purple Player" (Player.name player);
  assert_equal (2,2) (Player.posn player);
  ae_tile (Tile.from ~players:[id] Tile.empty) (Dynamo.get_tile dynamo (2,2))

let add_three_players_two_to_same_tile _ =
  (* lets make sure that adding a few players keeps the right state *)
  let open Game_op in
  let ops = [create (Add_player ("Purple Player", None)) (2,2);
             create (Add_player ("Red Player", None)) (2,2);
             create (Add_player ("Blue Player", None)) (3,5);
            ] in
  let dynamo = run_with_ops ops in
  let players = Dynamo.players dynamo |> Hashtbl.to_alist in
  assert_equal 3 (List.length players);
  (* Ignore the ids, are the players correct? *)
  let players_sorted = List.map ~f:(fun (_,p) -> Player.name p, Player.posn p) players
                       |> List.sort ~cmp:(fun (n1,_) (n2,_) -> String.compare n1 n2)
  in
  assert_equal ["Blue Player", (3,5);
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
  let player = Hashtbl.find_exn (Dynamo.players dynamo) id in
  assert_equal (3,3) (Player.posn player);
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
             create Add_tree (2,3);
             create Add_tree (2,3);
             create Add_rock (2,3);
             create Add_rock (2,3);] in
  let dynamo = run_with_ops ops in
  create (Player_harvest (id, Resources.Wood)) (2,3)
  |> Dynamo.add_op dynamo
  |> assert_equal Result.ok_unit;
  Dynamo.step dynamo;
  assert_equal 1 (Hashtbl.find_exn (Dynamo.players dynamo) id
                  |> Player.resources |> Resources.get ~kind:Resources.Wood);
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
  let game = Game.create [Game_op.(create Add_tree (1,2))] (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  ae_tile (make_tile [Resources.Wood,1]) (Dynamo.get_tile dynamo (1,2))

let add_rock _ =
  let game = Game.create [Game_op.(create Add_rock (1,2))] (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  ae_tile (make_tile [Resources.Rock,1]) (Dynamo.get_tile dynamo (1,2))

let add_rock_and_tree_same_tile _ =
  let ops = Game_op.([create Add_rock (1,2);
                      create Add_tree (1,2)]) in
  let game = Game.create ops (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  let () = Dynamo.step dynamo in
  ae_tile (make_tile [Resources.Rock,1; Resources.Wood,1] ) (Dynamo.get_tile dynamo (1,2))

let add_rock_and_tree_different_tiles _ =
  let ops = Game_op.([create Add_rock (2,3);
                      create Add_tree (1,2)]) in
  let game = Game.create ops (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  let () = Dynamo.step dynamo in
  ae_tile (make_tile [Resources.Rock,1]) (Dynamo.get_tile dynamo (2,3));
  ae_tile (make_tile [Resources.Wood,1]) (Dynamo.get_tile dynamo (1,2))

let multiple_adds _ =
  let ops = Game_op.([create Add_rock (2,3);
                      create Add_rock (2,3);
                      create Add_tree (2,3);
                      create Add_tree (1,2);
                      create Add_rock (5,5);
                      create Add_rock (5,5);
                      create Add_rock (5,5);
                     ]) in
  let game = Game.create ops (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.run dynamo in
  ae_tile (make_tile Resources.([Wood, 1; Rock, 2])) (Dynamo.get_tile dynamo (2,3));
  ae_tile (make_tile [Resources.Wood, 1]) (Dynamo.get_tile dynamo (1,2));
  ae_tile (make_tile [Resources.Rock, 3]) (Dynamo.get_tile dynamo (5,5))

let remove_tree _ =
  let ops = Game_op.([create Add_rock (1,2);
                      create Add_tree (1,2);
                      create Remove_tree (1,2);]) in
  let game = Game.create ops (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.run dynamo in
  ae_tile (make_tile [Resources.Rock, 1]) (Dynamo.get_tile dynamo (1,2))

let remove_rock _ =
  let ops = Game_op.([create Add_rock (1,2);
                      create Add_tree (1,2);
                      create Remove_rock (1,2);]) in
  let game = Game.create ops (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.run dynamo in
  ae_tile (make_tile [Resources.Wood, 1]) (Dynamo.get_tile dynamo (1,2))

let illegal_remove_tree _ =
  let game = Game.create [Game_op.(create Remove_tree (1,2))] (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  ae_tile (make_tile [Resources.Wood, -1]) (Dynamo.get_tile dynamo (1,2))

let illegal_remove_rock _ =
  let game = Game.create [Game_op.(create Remove_rock (1,2))] (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  ae_tile (make_tile [Resources.Rock, -1]) (Dynamo.get_tile dynamo (1,2))

let suite =
  "dynamo suite">:::
  [
    "empty apply">::empty_apply;
    "add one player">::add_one_player;
    "add three players two same tile">::add_three_players_two_to_same_tile;
    "move one player">::move_one_player;
    "run player message">::run_player_message;
    "add player message valid">::add_player_message_valid;
    "add player message invalid player">::add_player_message_invalid_player;
    "add player message invalid position">::add_player_message_invalid_position;
    "add & run player harvest wood success">::add_and_run_player_harvest_wood_success;
    "add player harvest wood failure no wood">::add_player_harvest_failure_no_resource;
    "add tree">::add_tree;
    "add rock">::add_rock;
    "add rock & tree same">::add_rock_and_tree_same_tile;
    "add rock & tree different">::add_rock_and_tree_different_tiles;
    "multiple rocks & trees">::multiple_adds;
    "remove tree">::remove_tree;
    "remove rock">::remove_rock;
    "illegal remove tree">::illegal_remove_tree;
    "illegal remove rock">::illegal_remove_rock;
  ]
