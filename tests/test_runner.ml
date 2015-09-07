open Core.Std
open Async.Std
open OUnit2

let () =
  let suites = [
    Test_dynamo.suite;
  ] in
  let _ = List.map ~f:(fun s -> run_test_tt_main s) suites in
  ();
  Test_event_sources.async_suite
  |> Async_ounit.make_tests "Dynamo"
  >>= Async_ounit.run_async_tests_code
  >>= Shutdown.exit
  |> don't_wait_for;
  never_returns (Scheduler.go ())
