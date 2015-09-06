open Core.Std
open Async.Std
open OUnit

type async_test = unit -> unit Deferred.t

exception Timeout with sexp

let timeout =
  Sys.getenv "AO_TIMEOUT"
  |> Option.value_map ~default:3.0 ~f:Float.of_string

let timeout_test test () =
  Clock.with_timeout (Time.Span.of_sec timeout) (test ()) >>| function
  | `Result a -> a
  | `Timeout -> raise Timeout

let make_tests suite_name tests =
  let results =
    tests
    |> Deferred.List.map ~how:`Sequential ~f:(fun (name, test) ->
      Log.Global.debug "Running %s" name;
      let res =
        try_with ~extract_exn:true (timeout_test test) >>| function
        | Ok () -> `Ok
        | Error exn -> `Exn exn in
      res >>| (fun res -> (name, res)))
  in
  results >>| (fun results ->
    let ounit_tests =
      results
      |> List.map ~f:(fun (name, res) ->
        name >:: fun _ -> (* TODO this should be unit? *)
          match res with
          | `Ok -> ()
          | `Exn x -> raise x
      ) in
    suite_name >::: ounit_tests)

let run_async_tests test =
  In_thread.run ~name:"OUnit tests" (fun () ->
    test |> OUnit.run_test_tt_main)

let run_async_tests_code test =
  run_async_tests test >>| fun results ->
  let have_failure =
    results |> List.exists ~f:(function
      | OUnit.RFailure (_, _)
      | OUnit.RError (_, _) -> true
      | _ -> false) in
  if have_failure then 1 else 0

let run_async_tests_shutdown test =
  test |> run_async_tests_code >>= Shutdown.exit
