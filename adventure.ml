open Core.Std
open Async.Std
module C = Cohttp
module CA = Cohttp_async

let respond ?(flush) ?(headers) ?(body) status_code =
  (* Wrapper around Server.respond so that we can catch the Server.respond
     type before it becomes abstract *)
  return (flush, headers, body, status_code)

let respond_with_file ?flush ?headers filename =
  (* This function exists so we can use our logger with it. Otherwise we
     would just use CA.Server.respond_with_file *)
  Monitor.try_with ~run:`Now
    (fun () ->
       Reader.open_file filename
       >>= fun rd ->
       let body = `Pipe (Reader.pipe rd) in
       let mime_type = Magic_mime.lookup filename in
       let headers = Cohttp.Header.add_opt_unless_exists headers "content-type" mime_type in
       return (flush, headers, body, `OK))
  >>= function
  | Ok (flush, headers, body, code) -> respond ?flush ~headers ~body code
  | Error exn -> respond ~body:(CA.Body.of_string "Error file not found") `Internal_server_error

let serve_file docroot uri =
  CA.Server.resolve_local_file ~docroot ~uri
  |> respond_with_file

let handler body sock req =
  let path = C.Request.uri req |> Uri.path in
  match path, C.Request.meth req with
  | "/", `GET
  | "/index.html", `GET -> serve_file "." (Uri.of_string "/index.html")
  | "/game.js", `GET -> serve_file "." (Uri.of_string "/game.js")
  | "/hello", `GET -> respond ~body:(CA.Body.of_string "{\"msg\":\"hey there!\"}") `OK
  | _ -> respond `Bad_request

let log_handler handler ~body sock request =
  (* This is a wrapper for the handler which outputs a log requests and
     responses in Common Log Format
     e.g. 127.0.0.1 GET /apache_pb.gif HTTP/1.0 200 Ok 2336 *)
  handler body sock request >>= fun (flush, headerss, body, status_code) ->
  let open C.Request in
  (* TODO this is horribly inefficient and only here to get the length of
     the body. Nix this. *)
  CA.Body.to_string (Option.value ~default:(CA.Body.of_string "") body) >>= fun s ->
  Log.Global.info "%s %s %s %s / %s %s %d"
    (Socket.Address.to_string sock)
    (C.Code.string_of_method request.meth)
    (Uri.to_string request.uri)
    (C.Transfer.string_of_encoding request.encoding)
    (C.Code.string_of_version request.version)
    (C.Code.string_of_status status_code)
    (String.length s);
  CA.Server.respond ?flush ?headers:headerss ~body:(CA.Body.of_string s) status_code

let determine_mode key_file cert_file =
  let file_must_exist ~msg filename =
    match Core.Std.Sys.file_exists filename with
    | `Yes -> ()
    | _ -> failwith (Printf.sprintf msg filename)
  in
  let open Conduit_async in
  match (key_file, cert_file) with
  | (Some k, Some c) ->
    let () = file_must_exist ~msg:"Error key file not found %s" k in
    let () = file_must_exist ~msg:"Error cert file not found %s" c in
    `OpenSSL (`Crt_file_path c, `Key_file_path k)
  | (None, None) -> `TCP
  | (Some _, None)
  | (None, Some _) -> failwith "Error must specify both key and cert"

let exception_handler _address exn =
  (* TODO how to catch this earlier and respond to client? *)
  Log.Global.error "Got an exception: %s" (Exn.to_string_mach exn)

let start_server port key_file cert_file () =
  Log.Global.info "adventure game server is starting up!";
  let mode = determine_mode key_file cert_file in
  Log.Global.info "Listening for %s on port %d"
    (match mode with `OpenSSL _ -> "HTTPS" | _ -> "HTTP") port;
  let handler = log_handler handler in
  CA.Server.create
    ~on_handler_error:(`Call exception_handler)
    ~mode
    (Tcp.on_port port) handler
  >>= fun _ -> Deferred.never ()

let () =
  Command.async_basic
    ~summary:"Simple http server that ouputs body of POST's"
    Command.Spec.(empty
                  +> flag "-p" (optional_with_default 8000 int)
                    ~doc:"int Source port to listen on"
                  +> flag "-key-file" (optional file)
                    ~doc:"File of private key."
                  +> flag "-cert-file" (optional file)
                    ~doc:"File of cert."
                 ) start_server
  |> Command.run ~version:"0.0.1" ~build_info:"foo"
