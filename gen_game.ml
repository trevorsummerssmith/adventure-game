open Core.Std

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

let doit seed num_players file () =
  let num_players = Option.value ~default:0 num_players in
  let seed = Option.value ~default:(Unix.gettimeofday () |> Int.of_float) seed in
  let player_names = get_player_names num_players in
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
      let op1 = Game_op.({posn=posn1; op=Add_tree}) in
      let op2 = Game_op.({posn=posn2; op=Add_rock}) in
      make_stuff (i-1) (op1::op2::aux)
  in
  let ops = make_stuff 20 [] in
  (* Make players *)
  let player_ops = gen_player_add_ops random_posn player_names in
  let ops = player_ops @ ops in
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
                  +> flag "-p" (optional int) ~doc:"Number of players"
                  +> anon ("filename" %: file))
    doit

let () =
  Command.run command
