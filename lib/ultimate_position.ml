open! Core_kernel

module T = struct
  type t = Position.t * Position.t [@@deriving sexp, compare, bin_io]
end

include T
include Comparable.Make (T)

let to_string t =
  Position.to_string (fst t)
  ^ " board, "
  ^ Position.to_string (snd t)
  ^ " space"
;;

let board t = fst t
let space_in_board t = snd t
let big_row t = Position.row (fst t)
let big_col t = Position.col (fst t)
let lil_row t = Position.row (snd t)
let lil_col t = Position.col (snd t)

let create row col lil_row lil_col : t =
  Position.create row col, Position.create lil_row lil_col
;;
