open Core.Std

let random_posn width height () =
  Random.int width, Random.int height

let doit seed file () =
  let seed = match seed with
    | Some i -> i
    | None -> (Unix.gettimeofday () |> Int.of_float)
  in
  Printf.printf "Using seed: %d %s\n" seed file;
  (* Generating random trees and rocks *)
  let width, height = 100, 100 in
  let random_posn = random_posn width height in
  let () = Random.init seed in
  (* We'll do something basic for now. Generate 20 trees
     and 20 rocks *)
  let rec make_stuff i aux =
    if i = 0 then
      aux
    else
      let posn1 = random_posn () in
      let posn2 = random_posn () in
      let op1 = Game_op.({posn=posn1; op=AddTree}) in
      let op2 = Game_op.({posn=posn2; op=AddRock}) in
      make_stuff (i-1) (op1::op2::aux)
  in
  let ops = make_stuff 20 [] in
  let game = {Game.ops; board_dimensions=(width,height)} in
  Out_channel.with_file file ~f:(fun oc ->
      Game.sexp_of_t game
      |> Sexp.to_string
      |> Out_channel.output_string oc
    )

let command =
  Command.basic
    ~summary:"Make a starting board"
    Command.Spec.(empty
                  +> flag "-s" (optional int) ~doc:"int. Random seed."
                  +> anon ("filename" %: file))
    doit

let () =
  Command.run command
