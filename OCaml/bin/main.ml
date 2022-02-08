open! Core
open! Async

let () =
  Command.async
    ~summary:"Play tick tac toe!"
    [%map_open.Command
      let () = return () in
      fun () ->
        let%bind () = Clock.after (sec 0.2) in
        Multi_uttt.User.start ()]
  |> Command.run
;;
