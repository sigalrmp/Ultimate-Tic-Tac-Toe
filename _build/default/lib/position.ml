open! Core_kernel

type t = int * int [@@deriving sexp, compare, equal, bin_io]

let to_string (v, h) =
  let v_to_s v =
    match v with
    | 0 -> "top"
    | 1 -> "center"
    | 2 -> "bottom"
    | _ -> failwith "row out of range"
  in
  let h_to_s h =
    match h with
    | 0 -> "left"
    | 1 -> "center"
    | 2 -> "right"
    | _ -> failwith "col out of range"
  in
  v_to_s v ^ " " ^ h_to_s h
;;

let row (t : t) = fst t
let col (t : t) = snd t
let create row col : t = row, col
let equal t t' = row t = row t' && col t = col t'
