open! Core_kernel

type t = Player.t Map.M(Ultimate_position).t [@@deriving bin_io]

let create () : t = Map.empty (module Ultimate_position)
let space (t : t) pos = Map.find t pos
let set_space (t : t) pos player : t = Map.set t ~key:pos ~data:player

let mini_score t big_pos player =
  let multiplier pos player' =
    let big_row = Position.row big_pos in
    let big_col = Position.col big_pos in
    let row = Position.row pos in
    let col = Position.col pos in
    let full_pos = Ultimate_position.create big_row big_col row col in
    let space = space t full_pos in
    match space with
    | None -> 0.5
    | Some s ->
      (match Player.equal s player' with
      | true -> 1.
      | false -> 0.)
  in
  Scoring.score ~player ~multiplier
;;

let score t player =
  let multiplier pos player' = mini_score t pos player' in
  Scoring.score ~player ~multiplier
;;

let is_finished (t : t) =
  let full = Map.length t = 81 in
  let won =
    match score t Player.X, score t Player.O with
    | a, b when Float.equal a 1. || Float.equal b 1. -> true
    | _ -> false
  in
  won || full
;;

let winner t =
  if not (is_finished t)
  then failwith "game not over"
  else (
    match score t Player.X, score t Player.O with
    | 1., _ -> Some Player.X
    | _, 1. -> Some Player.O
    | _ -> None)
;;

let miniboard_is_finished (t : t) pos =
  let full =
    let is_in_board pos' = Position.equal pos (Ultimate_position.board pos') in
    let count =
      Map.fold t ~init:0 ~f:(fun ~key:p ~data:_ count ->
          if is_in_board p then count + 1 else count)
    in
    count = 9
  in
  let won =
    match mini_score t pos Player.X, mini_score t pos Player.O with
    | 1., _ -> true
    | _, 1. -> true
    | _ -> false
  in
  full || won
;;

let to_string (t : t) =
  let p = Ultimate_position.create in
  let b = Buffer.create 0 in
  let print s = Buffer.add_string b s in
  for outer_row = 0 to 2 do
    for inner_row = 0 to 2 do
      for outer_col = 0 to 2 do
        for inner_col = 0 to 2 do
          print
            (match Map.find t (p outer_row outer_col inner_row inner_col) with
            | None -> "- "
            | Some X -> "x "
            | Some O -> "o ")
        done;
        print " "
      done;
      print "\n"
    done;
    print "\n"
  done;
  Buffer.contents b
;;

let print t = print_endline (to_string t)

let%expect_test _ =
  let board = create () in
  let board = set_space board (Ultimate_position.create 1 2 0 1) X in
  let board = set_space board (Ultimate_position.create 0 0 0 0) O in
  print_endline (to_string board);
  [%expect
    {|
    o - -  - - -  - - -
    - - -  - - -  - - -
    - - -  - - -  - - -

    - - -  - - -  - x -
    - - -  - - -  - - -
    - - -  - - -  - - -

    - - -  - - -  - - -
    - - -  - - -  - - -
    - - -  - - -  - - - |}]
;;
