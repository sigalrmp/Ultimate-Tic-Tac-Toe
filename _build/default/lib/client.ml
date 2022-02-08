open! Core
open! Async
open! Notty_async

type t =
  { mutable model : Model.t
  ; mutable cursor : Cursor_pos.t
  ; connection : Connection.t
  ; player : Player.t
  }

let send_action (t : t) =
  let action = Action.Move { player = t.player; move = t.cursor.pos } in
  match t.connection with
  | Connection.Server conn ->
    (match%map Rpc.Rpc.dispatch Protocol.apply_action conn action with
    | Ok () -> ()
    | Error error ->
      raise_s [%message "dispatch apply_action failed" (error : Error.t)])
  | Connection.Ai r ->
    Ai_game.apply_action r.game action;
    return ()
;;

let move_f dir =
  match dir with
  | `Up -> Cursor_pos.up
  | `Down -> Cursor_pos.down
  | `Left -> Cursor_pos.left
  | `Right -> Cursor_pos.right
;;

let move_is_valid t =
  Player.equal t.player t.model.turn
  && Option.is_none (Board.space t.model.board t.cursor.pos)
  && not
       (Board.miniboard_is_finished
          t.model.board
          (Ultimate_position.board t.cursor.pos))
;;

let handle_events (t : t) events =
  Pipe.iter events ~f:(fun ev ->
      match ev with
      | `Key (`Arrow dir, _) ->
        t.cursor <- (move_f dir) t.cursor;
        return ()
      | `Key (`Enter, _) -> if move_is_valid t then send_action t else return ()
      | `Key (`ASCII 'C', [ `Ctrl ]) ->
        Pipe.close_read events;
        return ()
      | _ -> return ())
;;

let update_pos (t : t) (Action.Move action) (cursor : Cursor_pos.t) =
  let board = Ultimate_position.space_in_board action.move in
  if Board.miniboard_is_finished t.model.board board
  then { cursor with restriction = None }
  else (
    let pos = Ultimate_position.create (fst board) (snd board) 0 0 in
    { Cursor_pos.pos; restriction = Some board })
;;

let handle_actions (t : t) actions =
  Pipe.iter_without_pushback actions ~f:(fun action ->
      t.model <- Model.apply_action t.model action;
      t.cursor <- update_pos t action t.cursor)
;;

let update_display (t : t) ~stop term =
  Clock.every' (sec 0.05) ~stop (fun () ->
      let%bind () = Term.image term (Model.render t.model) in
      let cursor_pos =
        if Player.equal t.model.turn t.player
        then Some (Cursor_pos.to_grid t.cursor)
        else None
      in
      Term.cursor term cursor_pos)
;;

let run (t : t) actions =
  let%bind term = Term.create () in
  let events = Term.events term in
  let stop = Deferred.any [ Pipe.closed events; Pipe.closed actions ] in
  don't_wait_for (handle_actions t actions);
  don't_wait_for (handle_events t events);
  update_display t ~stop term;
  stop
;;

let server_connect_and_run host_and_port name =
  let%bind conn =
    match%map
      Rpc.Connection.client
        (Tcp.Where_to_connect.of_host_and_port host_and_port)
    with
    | Ok client -> client
    | Error exn -> raise exn
  in
  match%bind Rpc.State_rpc.dispatch Protocol.subscribe conn name with
  | Ok (Error _) -> .
  | Error error ->
    raise_s [%message "Dispatch of subscribe failed" (error : Error.t)]
  | Ok (Ok (player, actions, _)) ->
    let t : t =
      { model = Model.create_blank ()
      ; cursor = Cursor_pos.create_init ()
      ; connection = Connection.Server conn
      ; player
      }
    in
    run t actions
;;

let connect_to_ai () =
  let%bind game, actions = Ai_game.subscribe () in
  let model = Model.create_blank () in
  let t : t =
    { model
    ; cursor = Cursor_pos.create_init ()
    ; connection = Connection.Ai { game; actions }
    ; player = Player.opponent game.ai.player
    }
  in
  run t actions
;;
