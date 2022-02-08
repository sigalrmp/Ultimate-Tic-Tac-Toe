open! Core_kernel

type t [@@deriving bin_io]

include Comparable.S with type t := t

val to_string : t -> string
val board : t -> Position.t
val space_in_board : t -> Position.t
val big_row : t -> int
val big_col : t -> int
val lil_row : t -> int
val lil_col : t -> int
val create : int -> int -> int -> int -> t
