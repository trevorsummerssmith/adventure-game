open OUnit2

let empty_apply _ =
  let game = Game.create [] (1,1) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  assert_equal Tile.empty_tile (Dynamo.get_tile dynamo (0,0))

let add_tree _ =
  let game = Game.create [Game_op.(create Add_tree (1,2))] (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  assert_equal Tile.({trees=1;rocks=0}) (Dynamo.get_tile dynamo (1,2))

let add_rock _ =
  let game = Game.create [Game_op.(create Add_rock (1,2))] (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  assert_equal Tile.({trees=0;rocks=1}) (Dynamo.get_tile dynamo (1,2))

let add_rock_and_tree_same_tile _ =
  let ops = Game_op.([create Add_rock (1,2);
		      create Add_tree (1,2)]) in
  let game = Game.create ops (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  let () = Dynamo.step dynamo in
  assert_equal Tile.({trees=1;rocks=1}) (Dynamo.get_tile dynamo (1,2))

let add_rock_and_tree_different_tiles _ =
  let ops = Game_op.([create Add_rock (2,3);
		      create Add_tree (1,2)]) in
  let game = Game.create ops (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  let () = Dynamo.step dynamo in
  assert_equal Tile.({trees=0;rocks=1}) (Dynamo.get_tile dynamo (2,3));
  assert_equal Tile.({trees=1;rocks=0}) (Dynamo.get_tile dynamo (1,2))

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
  for i = 0 to Game.num_ops dynamo.Dynamo.game do
    Dynamo.step dynamo
  done;
  assert_equal Tile.({trees=1;rocks=2}) (Dynamo.get_tile dynamo (2,3));
  assert_equal Tile.({trees=1;rocks=0}) (Dynamo.get_tile dynamo (1,2));
  assert_equal Tile.({trees=0;rocks=3}) (Dynamo.get_tile dynamo (5,5))

let remove_tree _ =
  let ops = Game_op.([create Add_rock (1,2);
		      create Add_tree (1,2);
		      create Remove_tree (1,2);]) in
  let game = Game.create ops (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  let () = Dynamo.step dynamo in
  let () = Dynamo.step dynamo in
  assert_equal Tile.({trees=0;rocks=1}) (Dynamo.get_tile dynamo (1,2))

let remove_rock _ =
  let ops = Game_op.([create Add_rock (1,2);
		      create Add_tree (1,2);
		      create Remove_rock (1,2);]) in
  let game = Game.create ops (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  let () = Dynamo.step dynamo in
  let () = Dynamo.step dynamo in
  assert_equal Tile.({trees=1;rocks=0}) (Dynamo.get_tile dynamo (1,2))

let illegal_remove_tree _ =
  let game = Game.create [Game_op.(create Remove_tree (1,2))] (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  assert_equal Tile.({trees=0;rocks=0}) (Dynamo.get_tile dynamo (1,2))

let illegal_remove_rock _ =
  let game = Game.create [Game_op.(create Remove_rock (1,2))] (10,10) in
  let dynamo = Dynamo.create game in
  let () = Dynamo.step dynamo in
  assert_equal Tile.({trees=0;rocks=0}) (Dynamo.get_tile dynamo (1,2))

let suite =
  "dynamo suite">:::
    [
      "empty apply">::empty_apply;
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
