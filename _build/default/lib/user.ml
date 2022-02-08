open! Core
open! Async

let rec multiplayer () =
  printf "would you like to run a server(s) or a client(c)? \n %!";
  match%bind Reader.read_line (force Reader.stdin) with
  | `Ok ("s" | "S") -> server ()
  | `Ok ("c" | "C") -> client ()
  | `Eof | `Ok _ ->
    printf "please answer with s, S, c or C\n";
    multiplayer ()

and server () = Server.start ~port:9999

and client () =
  let%bind host =
    printf "what host would you like to play with (localhost)? \n %!";
    match%bind Reader.read_line (force Reader.stdin) with
    | `Ok "" -> return "localhost"
    | `Ok s -> return s
    | `Eof -> failwith "failed in User.client (in host)"
  in
  let%bind name =
    printf "what is the name of the room that you are joining/creating? \n %!";
    match%bind Reader.read_line (force Reader.stdin) with
    | `Ok s -> return s
    | `Eof -> failwith "failed with User.client (in name)"
  in
  Client.server_connect_and_run (Host_and_port.create ~host ~port:9999) name
;;

let ai () = Client.connect_to_ai ()

let rec start () =
  printf
    "welcome to ultimate tic tac toe!\n\
     would you like to play multiplayer(m) or against an ai(a)? \n\
    \ %!";
  match%bind Reader.read_line (force Reader.stdin) with
  | `Ok ("m" | "M") -> multiplayer ()
  | `Ok ("a" | "A") -> ai ()
  | `Eof | `Ok _ ->
    printf "please respond with m, M, a or A\n%!";
    start ()
;;
