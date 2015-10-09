open Core.Std
open Async.Std

let update_buildable ?(after=Async.Std.after) buildable_id w_ops r_resp =
  let open Things.Buildable in
  let send_op status =
    let op = Game_op.(create (Buildable_update (buildable_id, status)) (0,0)) in
    Pipe.write w_ops op >>= fun () ->
    Pipe.read r_resp >>| function
    | `Eof -> failwith "Something very wrong: Pipe closed prematurely"
    | `Ok _resp -> () (* TODO Ignorning the response for now *)
  in
  let rec loop percent =
    after (sec 10.) >>> fun () ->
    if percent >= 100 then begin
      send_op Atoms.Complete >>> fun () ->
      Pipe.close w_ops end
    else begin
      send_op (Atoms.Building percent) >>> fun () ->
      loop (percent + 10) end
  in
  return (loop 10)
