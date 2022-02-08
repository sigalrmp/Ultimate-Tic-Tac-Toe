open! Core_kernel

type t =
  | X
  | O
[@@deriving compare, equal, bin_io]

let random () =
  match Random.int 2 with
  | 0 -> X
  | 1 -> O
  | _ -> failwith "something went wrong in Player.random"
;;

let opponent t =
  match t with
  | X -> O
  | O -> X
;;

let to_string t =
  match t with
  | X -> "x"
  | O -> "o"
;;