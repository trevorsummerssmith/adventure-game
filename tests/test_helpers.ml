open Core.Std
open Async.Std
open OUnit2

let after_trivial _span = Deferred.unit

let run_with_ops ?(dimensions=(10,10)) ops =
  (* Helper function to create a Dynamo with [ops] and run them.
     Uses a trivial implementation of [after] for the Dynamo.
  *)
  let dynamo = Game.create ops dimensions |> Dynamo.create in
  Dynamo.run dynamo;
  dynamo

let ae_sexp ?cmp ?pp_diff ?msg sexp a a' =
  assert_equal ?cmp ?pp_diff ?msg
    ~printer:(fun x -> x |> sexp |> Sexp.to_string_hum) a a'

let ae_uuid_list ls ls' =
  ae_sexp <:sexp_of<Uuid.t list>> ls ls'

let ae_player p p' =
  ae_sexp ~cmp:(fun a b -> (Player.compare a b) = 0) Player.sexp_of_t p p'

let ae_tile t t' =
  let cmp a b = (Tile.shallow_compare a b) = 0 in
  ae_sexp ~cmp Tile.sexp_of_t t t'

let ae_game_op op op' =
  (* Ignore Game_op's time (because it is computer assigned) *)
  ae_sexp ~cmp:(fun a b ->
      let open Game_op in
      ((Poly.compare a.posn b.posn) = 0)
      && ((compare_code a.code b.code) = 0))
    Game_op.sexp_of_t op op'

let assert_from_pipe pipe ae answer =
  Pipe.read pipe >>| (function
  | `Eof -> failwith "assert_from_pipe: expected `Ok got `Eof"
  | `Ok a -> ae answer a)
  >>> fun () -> ()

let assert_players_on_board dynamo =
  (* Asserts that the list of players in the dynamo have the positions as the
     tiles on the board. N.b. does not do the other way! There could be a player
     on board tile not in the player list and this function would not raise *)
  (* A list of lists where each list is the set of players on the same tile *)
  let get_posn = Props.get_posn (Dynamo.store dynamo) in
  let players_by_posn =
    Dynamo.players dynamo
    |> List.sort ~cmp:(fun id1 id2 -> compare (get_posn id1) (get_posn id2))
    |> List.group ~break:(fun id1 id2 -> (get_posn id1) <> (get_posn id2))
  in
  List.iter ~f:(fun players ->
      let posn = List.hd_exn players |> get_posn in
      let tile_player_ids = Dynamo.get_tile dynamo posn |> Props.players in
      assert_equal
        (List.sort ~cmp:Uuid.compare tile_player_ids)
        (List.sort ~cmp:Uuid.compare players)
    ) players_by_posn

let make_tile ?(players=[]) (resources : (Resources.kind,int) List.Assoc.t) =
  let resources = Resources.of_alist_exn resources in
  Tile.create ~players ~resources ~messages:[] ()
