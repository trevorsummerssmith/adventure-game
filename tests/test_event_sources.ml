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
    [ Atoms.Building 10
    ; Atoms.Building 20
    ; Atoms.Building 30
    ; Atoms.Building 40
    ; Atoms.Building 50
    ; Atoms.Building 60
    ; Atoms.Building 70
    ; Atoms.Building 80
    ; Atoms.Building 90
    ; Atoms.Complete
    ];
  return ()

let async_suite =
  [ "update buildable event source", event_sources_update_buildable_action
  ]
