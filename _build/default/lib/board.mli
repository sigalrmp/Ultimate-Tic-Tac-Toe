type t [@@deriving bin_io]

val create : unit -> t
val space : t -> Ultimate_position.t -> Player.t option
val set_space : t -> Ultimate_position.t -> Player.t -> t
val score : t -> Player.t -> float
val is_finished : t -> bool
val winner : t -> Player.t option
val miniboard_is_finished : t -> Position.t -> bool
val print : t -> unit
val to_string : t -> string