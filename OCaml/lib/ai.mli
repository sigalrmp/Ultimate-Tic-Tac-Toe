type t

val max_depth : int
val create : player:Player.t -> depth:int -> board:Board.t -> t

val next_move
  :  ai:t
  -> last_move:Ultimate_position.t option
  -> Ultimate_position.t
