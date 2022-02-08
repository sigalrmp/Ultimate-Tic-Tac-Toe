open! Core_kernel

type t =
  { player : Player.t
  ; depth : int
  ; board : Board.t
  }

(*should it also have the board or does that change?*)

type opt_data =
  { move : Ultimate_position.t option
  ; score : float
  }

type alpha_beta =
  { alpha : float
  ; beta : float
  }

type check_move_arguments =
  { t : t
  ; moves : Ultimate_position.t list
  ; alpha_beta : alpha_beta
  ; player : Player.t
  ; layer : int
  ; opt_data : opt_data
  ; opt : Opt.t
  }

let max_depth = 9

let create ~player ~depth ~board =
  match depth > max_depth with
  | true -> failwith "depth cannot be higher than max_depth"
  | false -> { player; depth; board }
;;

let all_pairs = List.cartesian_product [ 0; 1; 2 ] [ 0; 1; 2 ]

let forced_outer outer is_valid =
  List.filter_map all_pairs ~f:(fun p ->
      let move =
        Ultimate_position.create (fst outer) (snd outer) (fst p) (snd p)
      in
      if is_valid move then Some move else None)
;;

let unforced_outer is_valid =
  List.filter_map
    (List.cartesian_product all_pairs all_pairs)
    ~f:(fun (outer, inner) ->
      let move =
        Ultimate_position.create (fst outer) (snd outer) (fst inner) (snd inner)
      in
      if is_valid move then Some move else None)
;;

let gen_all_moves board (last_move : Ultimate_position.t option) =
  let is_valid move =
    match Board.space board move with
    | None -> true
    | Some _ -> false
  in
  match last_move with
  | None -> unforced_outer is_valid
  | Some move ->
    let miniboard = Ultimate_position.space_in_board move in
    (match Board.miniboard_is_finished board miniboard with
    | true -> unforced_outer is_valid
    | false -> forced_outer miniboard is_valid)
;;

let better_score opt score opt_score =
  (Opt.equal opt Opt.Min && Float.(score < opt_score))
  || (Opt.equal opt Opt.Max && Float.(score > opt_score))
;;

let time_to_prune player score alpha beta opp =
  if Player.equal player opp
  then Float.(score >= alpha)
  else Float.(score <= beta)
;;

let update ~arguments ~next_score ~move ~tail =
  let me = arguments.t.player in
  let opp = Player.opponent me in
  let score, move =
    if better_score arguments.opt next_score arguments.opt_data.score
    then next_score, Some move
    else arguments.opt_data.score, arguments.opt_data.move
  in
  let opt_data = { move; score } in
  let beta =
    if Player.equal arguments.player me
       && Float.(next_score > arguments.alpha_beta.beta)
    then next_score
    else arguments.alpha_beta.beta
  in
  let alpha =
    if Player.equal arguments.player opp
       && Float.(next_score < arguments.alpha_beta.alpha)
    then next_score
    else arguments.alpha_beta.alpha
  in
  let alpha_beta = { alpha; beta } in
  let moves = tail in
  { arguments with alpha_beta; opt_data; moves }
;;

let rec next_move_h (t : t) player layer last_move alpha_beta =
  let me = t.player in
  let board = t.board in
  let depth = t.depth in
  let opt = if Player.equal player me then Opt.Max else Opt.Min in
  let current_score = Board.score board me in
  if layer = depth || Board.is_finished board
  then
    { move = last_move
    ; score =
        current_score (*I think this is right but it's something to check*)
    }
  else (
    let moves = gen_all_moves board last_move in
    let opt_data =
      { move = None
      ; score =
          (match opt with
          | Opt.Max -> 0.
          | Opt.Min -> 1.)
      }
    in
    let check_move_arguments =
      { t; moves; alpha_beta; player; layer; opt_data; opt }
    in
    check_move check_move_arguments)

and check_move arguments : opt_data =
  let me = arguments.t.player in
  let opp = Player.opponent me in
  let board = arguments.t.board in
  match arguments.moves with
  | [] -> arguments.opt_data
  | move :: tail ->
    let next_board = Board.set_space board move arguments.player in
    let next_t = { arguments.t with board = next_board } in
    let next_player = Player.opponent arguments.player in
    let next_score =
      (next_move_h
         next_t
         next_player
         (arguments.layer + 1)
         (Some move)
         arguments.alpha_beta)
        .score
    in
    let prune =
      time_to_prune
        next_player
        next_score
        arguments.alpha_beta.alpha
        arguments.alpha_beta.beta
        opp
    in
    if prune
    then { move = Some move; score = next_score }
    else check_move (update ~arguments ~next_score ~move ~tail)
;;

let next_move ~ai:(t : t) ~last_move =
  let me = t.player in
  let move = (next_move_h t me 0 last_move { alpha = 1.; beta = 0. }).move in
  match move with
  | None -> failwith "something is wrong in Ai._next_move"
  | Some m -> m
;;
