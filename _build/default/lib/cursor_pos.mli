type t =
  { pos : Ultimate_position.t
  ; restriction : Position.t option
  }

val create_init : unit -> t
val up : t -> t
val left : t -> t
val down : t -> t
val right : t -> t
val to_grid : t -> int * int