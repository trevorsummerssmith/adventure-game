open Core.Std
open Async.Std

(*
   Player location data is denormalized and represented in both the board
   and the player.** Invariant: the player location and board location of a player
   should always be the same.
*)

type t =
  { mutable game : Game.t
  ; board : Board.t
  ; mutable players : Entity.Id.t list
  (* Ids of the players in the game.
     Currently this is only used to get the list of players at the beginning
     of the game. *)
  ; artifacts : (Uuid.t, Things.artifact) Hashtbl.t
  (* Mapping from artifact id to artifact *)
  ; buildables : (Uuid.t, Things.Buildable.t) Hashtbl.t
  (* Mapping from artifact id to buildable *)
  ; store : Entity_store.t
  (* State to keep track of most everything in the game. *)
  ; mutable tick : int
  (* Time in the game.
     This starts at 0 and is an index into the game ops. It represents
     the the next instruction to be ran. The board represents op tick-1.
  *)
  }

let get_tile dynamo posn =
  Board.get dynamo.board posn
  |> Entity_store.get_exn dynamo.store

let create game =
  (* Make a game board and then our tiles *)
  let board = Game.board_dimensions game |> Board.create in
  let store = Entity_store.create () in
  let make_tile _x _y id =
    Tile.create ~id ~resources:Resources.empty ~players:[] ~messages:[] ()
    |> Entity_store.replace store id
  in
  ignore(Board.mapi board ~f:make_tile);
  { game
  ; board
  ; players = []
  ; artifacts = Uuid.Table.create ()
  ; buildables = Uuid.Table.create ()
  ; store
  ; tick = 0
  }

let validate_player dynamo id =
  match Entity_store.get dynamo.store id with
  | None -> Or_error.error_string "Player not found"
  | Some p -> Result.Ok p

let validate_player_and_posn dynamo id posn =
  (* 1 Player must exist
     2 Player is on the same position as posn *)
  let open Or_error.Monad_infix in
  validate_player dynamo id >>= fun player ->
  let player_posn = Props.get_posn dynamo.store id in
  if player_posn = posn then
    Result.ok_unit
  else
    let x,y = posn in
    let p_x,p_y = player_posn in
    Or_error.errorf "Player not on right position. Board player is at: (%d,%d) \
                     Action at: (%d,%d)"
      p_x p_y x y

let validate_player_message dynamo (id, _time, _text) posn : unit Or_error.t =
  (* 1 Player must exist
     2 Player must be on the same tile as where the talking is taking place
     N.B. we're not doing any checks on the time right now
  *)
  validate_player_and_posn dynamo id posn

let validate_player_harvest dynamo id posn kind : unit Or_error.t =
  (* 1 Player must exist
     2 Player must be on right tile
     3 There must be resource >= 1
  *)
  let open Or_error.Monad_infix in
  validate_player_and_posn dynamo id posn >>= fun () ->
  let amt = get_tile dynamo posn |> Props.resources |> Resources.get ~kind in
  if amt >= 1 then
    Result.ok_unit
  else
    Or_error.error_string "Must be >= 1 resource to harvest"

let validate_player_create_artifact dynamo player_id text =
  (* Validate the player exists and they have the right resources:
     1 tree and 1 wood
     And that the message is non-zero in length
  *)
  let open Or_error.Monad_infix in
  validate_player dynamo player_id >>= fun player ->
  let resources = Props.get_resources dynamo.store player_id
                  |> Resources.get in
  let wood = resources ~kind:Resources.Wood in
  let rock = resources ~kind:Resources.Rock in
  if String.length text < 1 then
    Or_error.error_string "Artifact requires some text"
  else if wood < 1 then
    Or_error.errorf "Artifact requires 1 wood. You have %d" wood
  else if rock < 1 then
    Or_error.errorf "Artifact requires 1 rock. You have %d" rock
  else
    Result.ok_unit

let add_op dynamo op =
  let open Or_error.Monad_infix in
  let open Game_op in
  let resp = match op.code with
    | Player_message (id, time, text) ->
      validate_player_message dynamo (id, time, text) op.posn
    | Player_harvest (id,kind) ->
      validate_player_harvest dynamo id op.posn kind
    | Player_create_artifact (player_id, text, artifact_id_op) ->
      validate_player_create_artifact dynamo player_id text
    | _ -> Ok ()
  in
  resp >>| fun () ->
  let game = Game.add_op dynamo.game op in
  dynamo.game <- game

let rec run_event_source dynamo
    ~(f: Game_op.t Pipe.Writer.t
      -> unit Or_error.t Pipe.Reader.t
      -> unit Deferred.t) =
  (* Event source function is responsible for closing the Game_op pipe *)
  let r_ops, w_ops = Pipe.create () in
  let r_resp, w_resp = Pipe.create () in
  (* Keep default pushback -- we want the writer function to block
     until its events have been processed *)
  (* Deferred.unit to ensure f is called asynchronously *)
  don't_wait_for (Deferred.unit >>= fun () -> f w_ops r_resp);
  (* Clean up *)
  don't_wait_for (Pipe.closed w_ops >>| fun () ->
                  Pipe.close_read r_resp);
  (* Validate and run ops *)
  don't_wait_for(Pipe.transfer r_ops w_resp ~f:(fun op ->
      (* Read the op validate and respond, if valid step

         NB add_op and run are currently within a bind, so
         they are guaranteed to be run together without a switch.
         This isn't important right now but both do mutate state.
         There's no specific reason at the moment why add_op and run
         need to be run in lock step, just want to make this explicit
         because it could lead to bugs if this is relied upon
      *)
      let resp = add_op dynamo op in
      (match resp with
       | Ok () -> step dynamo
       | Error _ -> ());
      resp))

and take_action dynamo op =
  (* Applies the action to the board *)
  let open Game_op in
  let tile_id = Board.get dynamo.board op.posn in
  match op.code with
  | Add_player (name, id_op) ->
    (* 1) Generate new id for player
       2) add to player structure
       3) add to board *)
    let player = Player.create ?id:id_op
        ~resources:Resources.empty ~posn:op.posn name in
    let player_id = Entity.id player in
    Entity_store.replace dynamo.store player_id player;
    Props.add_to_players dynamo.store ~id:tile_id ~player:player_id;
    dynamo.players <- player_id :: dynamo.players
  | Move_player player_id ->
    (* 1. Find player's current position and remove it *)
    Props.get_posn dynamo.store player_id
    |> Board.get dynamo.board
    (* TODO why can't I just pipe this in there? *)
    |> fun id -> Props.remove_from_players dynamo.store ~id ~player:player_id;
    (* 2. Update new tile *)
    Props.add_to_players dynamo.store ~id:tile_id ~player:player_id;
    (* 3. Update player position *)
    Props.set_posn dynamo.store player_id op.posn
  | Player_message (player_id, time, text) ->
    (* Update tile with message. Re-sort to make sure its in time order *)
    let msg = Message.({player_id;time;text}) in
    let messages = msg :: (Props.get_messages dynamo.store tile_id)
                   |> List.sort ~cmp:(fun a b -> (Time.compare a.Message.time b.Message.time)) in
    Props.set_messages dynamo.store tile_id messages
  | Player_harvest (player_id, kind) ->
    (* 1. Update the player 2. Update the board *)
    let amt = Props.get_resources dynamo.store tile_id
              |> Resources.get ~kind |> pred in
    assert (amt >= 0);
    Props.get_resources dynamo.store player_id
    |> Resources.incr ~kind
    |> Props.set_resources dynamo.store player_id;
    Props.get_resources dynamo.store tile_id
    |> Resources.decr ~kind
    |> Props.set_resources dynamo.store tile_id;
  | Player_create_artifact (player_id, text, id_op) ->
    (* 1. Remove the cost from the player.
       2. Create artifact and add as a Buildable.
       3. Add buildable to player.
       4. Create an event source to build the artifact
    *)
    let update_player player_id artifact_id =
      let resources = Entity_store.get_exn dynamo.store player_id
                      |> Props.resources in
      assert (Resources.(get resources ~kind:Wood) >= 1);
      assert (Resources.(get resources ~kind:Rock) >= 1);
      Props.set_resources dynamo.store player_id resources;
      Props.add_to_buildables dynamo.store player_id artifact_id;
    in
    let id = Option.value ~default:(Uuid.create ()) id_op in
    update_player player_id id;
    let artifact = Things.({id; player_id; text}) in
    let buildable = Things.Buildable.({entity=artifact; percent_complete=(Building 0);}) in
    Hashtbl.add_exn dynamo.buildables ~key:id ~data:buildable;
    run_event_source dynamo ~f:(fun w_ops r_resp -> Event_sources.update_buildable id w_ops r_resp)
  | Buildable_update (id, status) ->
    (* If status update is Building, update the Buildable with that status,
       If Complete
         1. Remove the Buildable from the game's buildables
         2. Add to the game's artifacts
         3. Remove buildable from player's buildables
         4. Add to the player's artifacts
    *)
    begin
      let open Things.Buildable in
      Log.Global.info "Buildable_update %s %s"
        (Sexp.to_string (Uuid.sexp_of_t id))
        (Sexp.to_string (Things.Buildable.sexp_of_status status));
      match status with
      | Building percent ->
        let buildable = Hashtbl.find_exn dynamo.buildables id in
        let buildable = {buildable with percent_complete = status} in
        Hashtbl.replace dynamo.buildables ~key:id ~data:buildable
      | Complete ->
        let artifact = (Hashtbl.find_exn dynamo.buildables id).entity in
        Hashtbl.remove dynamo.buildables id;
        Hashtbl.add_exn dynamo.artifacts ~key:id ~data:artifact;
        (* Remove from the user *)
        let player_id = artifact.Things.player_id in
        Props.remove_from_buildables dynamo.store player_id id;
        Props.add_to_artifacts dynamo.store player_id artifact.Things.id
    end
  | Add_resource kind ->
    Props.get_resources dynamo.store tile_id
    |> Resources.incr ~kind
    |> Props.set_resources dynamo.store tile_id
  | Remove_resource kind ->
    Props.get_resources dynamo.store tile_id
    |> Resources.decr ~kind
    |> Props.set_resources dynamo.store tile_id

and step dynamo =
  if dynamo.tick >= Game.num_ops dynamo.game then
    ()
  else
    let op = Game.nth_op dynamo.game dynamo.tick in
    let () = take_action dynamo op in
    dynamo.tick <- (dynamo.tick + 1)

let run dynamo =
  for i = 0 to Game.num_ops dynamo.game do
    step dynamo
  done

let players dynamo =
  dynamo.players

let dimensions dynamo =
  (* TODO should probably nix this *)
  dynamo.board.Board.dimensions

let game dynamo =
  dynamo.game

let board dynamo =
  dynamo.board

let artifacts {artifacts; _} = artifacts

let buildables {buildables; _} = buildables

let store {store; _} = store
