type t =
  | X
  | O
[@@deriving bin_io]

val random : unit -> t
val opponent : t -> t
val equal : t -> t -> bool
val to_string : t -> string
