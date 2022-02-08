open! Core
open! Async
open! Notty

type ai_const =
  { depth : int
  ; player : Player.t
  }

type t =
  { ai : ai_const
  ; mutable model : Model.t
  ; writer : Action.t Pipe.Writer.t
  }

let rec choose_depth () =
  printf
    "what level would you like to play on: easy(e), medium(m), hard(h), \
     genius(g) or custom(c) (genius will be slow)? \n\
    \ %!";
  match%bind Reader.read_line (force Reader.stdin) with
  | `Ok ("e" | "E") -> return Constants.easy_depth
  | `Ok ("m" | "M") -> return Constants.medium_depth
  | `Ok ("h" | "H") -> return Constants.hard_depth
  | `Ok ("g" | "G") -> return Constants.genius_depth
  | `Ok ("c" | "C") -> custom ()
  | `Eof | `Ok _ ->
    printf "please answer with e, E, m, M, h, H, g, G, c or C\n";
    choose_depth ()

and custom () =
  printf
    "how many turns would you like the AI to be able to look ahead? (0 - 7) \n\
    \ %!";
  match%bind Reader.read_line (force Reader.stdin) with
  | `Ok "0" -> return 0
  | `Ok "1" -> return 1
  | `Ok "2" -> return 2
  | `Ok "3" -> return 3
  | `Ok "4" -> return 4
  | `Ok "5" -> return 5
  | `Ok "6" -> return 6
  | `Ok "7" -> return 7
  | _ ->
    printf "please answer with a number from 0 to 7\n";
    choose_depth ()
;;

let rec choose_player () =
  printf
    "would you like to be player x (and go first) or player o (and go second)? \n\
    \ %!";
  match%bind Reader.read_line (force Reader.stdin) with
  | `Ok ("o" | "O") -> return Player.O
  | `Ok ("x" | "X") -> return Player.X
  | `Eof | `Ok _ ->
    printf "please answer with x, X, o or O\n";
    choose_player ()
;;

let ai_move t last_move =
  let ai =
    Ai.create ~player:t.ai.player ~depth:t.ai.depth ~board:t.model.board
  in
  Action.Move { move = Ai.next_move ~ai ~last_move; player = t.ai.player }
;;

let subscribe () =
  let%bind depth = choose_depth () in
  let%bind player = choose_player () in
  let ai = { depth; player = Player.opponent player } in
  let reader, writer = Pipe.create () in
  let t = { ai; model = Model.create_blank (); writer } in
  if Player.equal t.model.turn t.ai.player
  then (
    let move = ai_move t None in
    t.model <- Model.apply_action t.model move;
    Pipe.write_without_pushback_if_open t.writer move);
  return (t, reader)
;;

let endgame t =
  match Board.winner t.model.board with
  | None -> printf "you tied. better luck next time!"
  | Some p ->
    if Player.equal p t.ai.player
    then printf "you lost. better luck next time!"
    else printf "you won!"
;;

let apply_action (t : t) (Action.Move action) =
  t.model <- Model.apply_action t.model (Action.Move action);
  Pipe.write_without_pushback_if_open t.writer (Action.Move action);
  if Board.is_finished t.model.board
  then endgame t
  else (
    let move = ai_move t (Some action.move) in
    t.model <- Model.apply_action t.model move;
    Pipe.write_without_pushback_if_open t.writer move;
    if Board.is_finished t.model.board then endgame t)
;;
