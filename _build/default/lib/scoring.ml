open! Core_kernel

let score_horizontal (player : Player.t) multiplier =
  let all = List.cartesian_product [ 0; 1; 2 ] [ 0; 1; 2 ] in
  let t, c, b =
    List.fold all ~init:(1., 1., 1.) ~f:(fun (t, c, b) pos ->
        let m_val = multiplier pos player in
        match fst pos (*row*) with
        | 0 -> t *. m_val, c, b
        | 1 -> t, c *. m_val, b
        | 2 -> t, c, b *. m_val
        | _ -> failwith "something's wrong in horizontal scoring")
  in
  (1. -. t) *. (1. -. c) *. (1. -. b)
;;

let score_vertical player multiplier =
  score_horizontal player (fun pos board ->
      multiplier (Position.create (Position.col pos) (Position.row pos)) board)
;;

let score_diagonal player multiplier =
  let score_1, score_2 =
    List.fold [ 0; 1; 2 ] ~init:(1., 1.) ~f:(fun (f, s) i ->
        ( f *. multiplier (Position.create i i) player
        , s *. multiplier (Position.create i (2 - i)) player ))
  in
  (1. -. score_1) *. (1. -. score_2)
;;

let gen_raw_score player multiplier =
  1.
  -. (score_horizontal player multiplier
     *. score_vertical player multiplier
     *. score_diagonal player multiplier)
;;

let score ~player ~multiplier =
  let player_raw_score = gen_raw_score player multiplier in
  let opp_raw_score = gen_raw_score (Player.opponent player) multiplier in
  match player_raw_score with
  | 1. -> 1.
  | _ ->
    (player_raw_score *. (1. -. opp_raw_score))
    +. ((player_raw_score ** 2.)
       *. opp_raw_score
       /. (player_raw_score +. opp_raw_score))
;;