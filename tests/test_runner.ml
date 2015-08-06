open OUnit2

let () =
  let suites = [
      Test_dynamo.suite;
  ] in
  let _ = List.map (fun s -> run_test_tt_main s) suites in
  ()
