open Core.Std
open Async.Std
open OUnit2
open Test_helpers

let event_sources_update_buildable_action () =
  (* Ensures that Event_source update works correctly *)
  let r_ops, w_ops = Pipe.create () in
  let r_resp, w_resp = Pipe.create () in
  let player_id = Uuid.create () in
  let ops = Game_op.([ create (Add_player ("Trevor", Some player_id)) (0,0)]) in
  let _dynamo = run_with_ops ops in
  let id = Uuid.create () in
  let after = after_trivial in
  don't_wait_for (Event_sources.update_buildable ~after id w_ops r_resp);
  let assert_pipe = assert_from_pipe r_ops ae_game_op in
  (* We should see 10 messages of building, then a Complete *)
  let f status =
    assert_pipe Game_op.(create (Buildable_update (id, status)) (0,0));
    (* Write ok response back as is required by the event source contract *)
    Pipe.write w_resp Result.ok_unit >>> fun () -> ()
  in
  List.iter ~f
    [ Things.Buildable.Building 10
    ; Things.Buildable.Building 20
    ; Things.Buildable.Building 30
    ; Things.Buildable.Building 40
    ; Things.Buildable.Building 50
    ; Things.Buildable.Building 60
    ; Things.Buildable.Building 70
    ; Things.Buildable.Building 80
    ; Things.Buildable.Building 90
    ; Things.Buildable.Complete
    ];
  return ()

let async_suite =
  [ "update buildable event source", event_sources_update_buildable_action
  ]
