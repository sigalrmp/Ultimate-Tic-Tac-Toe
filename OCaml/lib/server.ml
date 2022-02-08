open! Core
open! Async

module State = struct
  type room =
    { mutable update_listeners : Action.t Pipe.Writer.t list
    ; player_one : Player.t
    ; player_two_here : unit Ivar.t
    }

  type t = { mutable rooms : room Map.M(String).t }

  let create () = { rooms = Map.empty (module String) }
end

let send_actions (room : State.room) action =
  room.update_listeners
    <- List.filter room.update_listeners ~f:(fun pipe ->
           Pipe.write_without_pushback_if_open pipe action;
           not (Pipe.is_closed pipe))
;;

let apply_action =
  Rpc.Rpc.implement'
    Protocol.apply_action
    (fun ((state : State.t), room_opt) action ->
      match !room_opt with
      | None -> ()
      | Some room ->
        (match Map.find state.rooms room with
        | None -> ()
        | Some room -> send_actions room action))
;;

let subscribe =
  Rpc.State_rpc.implement
    Protocol.subscribe
    (fun ((state : State.t), room_opt) room ->
      room_opt := Some room;
      let r, w = Pipe.create () in
      match Map.find state.rooms room with
      | None ->
        let player_two_here = Ivar.create () in
        let room_data =
          { State.update_listeners = [ w ]
          ; player_one = Player.random ()
          ; player_two_here
          }
        in
        state.rooms <- Map.set state.rooms ~key:room ~data:room_data;
        let%bind () = Ivar.read player_two_here in
        return (Ok (room_data.player_one, r))
      | Some room_data ->
        Ivar.fill room_data.player_two_here ();
        room_data.update_listeners <- w :: room_data.update_listeners;
        return (Ok (Player.opponent room_data.player_one, r)))
;;

let implementations =
  Rpc.Implementations.create_exn
    ~on_unknown_rpc:`Raise
    ~implementations:[ apply_action; subscribe ]
;;

let start ~port =
  let%bind server =
    let state = State.create () in
    Rpc.Connection.serve
      ~implementations
      ~where_to_listen:(Tcp.Where_to_listen.of_port port)
      ~initial_connection_state:(fun _ _ -> state, ref None)
      ()
  in
  Tcp.Server.close_finished server
;;

let command =
  Command.async
    ~summary:"Start game server"
    [%map_open.Command
      let port =
        flag
          "-port"
          (optional_with_default Protocol.default_port int)
          ~doc:" Port to listen to"
      in
      fun () -> start ~port]
;;
