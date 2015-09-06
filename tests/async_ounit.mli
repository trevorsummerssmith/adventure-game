(** Simple wrapper around oUnit to make it easier to test async code *)

open Core.Std
open Async.Std

type async_test = unit -> unit Deferred.t

val make_tests : string -> (string * async_test) list -> OUnit.test Deferred.t

(** Run tests asynchronously and return the results *)
val run_async_tests : OUnit.test -> OUnit.test_results Deferred.t

val run_async_tests_code : OUnit.test -> int Deferred.t

(** Run tests and then shutdown with the correct status code *)
val run_async_tests_shutdown : OUnit.test -> 'a Deferred.t
