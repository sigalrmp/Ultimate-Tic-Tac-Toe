open! Core

type t =
  { board : Board.t
  ; turn : Player.t
  }
[@@deriving bin_io]

let create_blank () = { board = Board.create (); turn = Player.X }

let apply_action t (Move action : Action.t) =
  { board = Board.set_space t.board action.move action.player
  ; turn = Player.opponent t.turn
  }
;;

open Notty

let render t =
  let board_str = Board.to_string t.board in
  let split_str = String.split_lines board_str in
  let images = List.map split_str ~f:(fun str -> I.string A.empty str) in
  I.vcat images
;;
