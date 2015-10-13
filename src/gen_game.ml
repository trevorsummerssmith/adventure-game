open Core.Std

let pick ls =
  List.length ls |> Random.int |> List.nth_exn ls

let random_posn width height () =
  Random.int width, Random.int height

let get_player_names num =
  let rec aux players num =
    if num = 0 then
      players
    else begin
      Printf.printf "Player %d name: " num;
      Out_channel.flush stdout;
      match In_channel.input_line stdin with
      | None -> aux players num
      | Some name -> aux (name::players) (num-1)
    end
  in
  aux [] num

let gen_player_add_ops random_posn player_names =
  List.map ~f:(fun name ->
      let uuid = Uuid.create () in
      Game_op.(create (Add_player (name, Some uuid)) (random_posn ())))
    player_names

let add_temples num_temples random_posn =
  let names = ["Green"
                     ;"Blue"
                     ;"Shiva"
                     ;"Mighty Alfonzo"] in
  let secrets = ["A diamond rat"
                       ;"A portal to another world"
                       ;"Something strange"] in
  let rec loop aux i =
    if i = 0 then
      aux
    else
      let name = pick names in
      let secret = pick secrets in
      let code = Game_op.Add_temple (name, secret) in
      let op = Game_op.create code (random_posn ()) in
      loop (op::aux) (i-1)
  in
  loop [] num_temples

let doit seed num_players num_temples file () =
  let seed = Option.value ~default:(Unix.gettimeofday () |> Int.of_float) seed in
  let player_names = get_player_names num_players in
  Printf.printf "Using seed: %d %s\n" seed file;
  (* Generating random trees and rocks *)
  let width, height = 100, 100 in
  let random_posn = random_posn width height in
  Random.init seed;
  (* We'll do something basic for now. Generate 20 trees
     and 20 rocks *)
  let rec make_stuff i aux =
    if i = 0 then
      aux
    else
      let posn1 = random_posn () in
      let posn2 = random_posn () in
      let op1 = Game_op.(create (Add_resource Resources.Wood) posn1) in
      let op2 = Game_op.(create (Add_resource Resources.Rock) posn2) in
      make_stuff (i-1) (op1::op2::aux)
  in
  let ops = make_stuff 20 [] in
  (* Make players and temples *)
  let player_ops = gen_player_add_ops random_posn player_names in
  let temple_ops = add_temples num_temples random_posn in
  let ops = player_ops @ temple_ops @ ops in
  let game = Game.create ops (width,height) in
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
                  +> flag "-p" (optional_with_default 2 int)
                    ~doc:"int Number of players. Defaults to 2"
                  +> flag "-t" (optional_with_default 1 int)
                    ~doc:"int How many temples. Defaults to 1"
                  +> anon ("filename" %: file))
    doit

let () =
  Command.run command
