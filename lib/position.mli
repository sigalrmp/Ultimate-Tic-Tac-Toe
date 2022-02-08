open! Core_kernel

type t = int * int [@@deriving sexp, compare, equal, bin_io]

val to_string : t -> string
val row : t -> int
val col : t -> int

(** [create row col] *)
val create : int -> int -> t
