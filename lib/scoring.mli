val score
  :  player:Player.t
  -> multiplier:(Position.t -> Player.t -> float)
  -> float

(*for testing*)

val score_horizontal : Player.t -> (Position.t -> Player.t -> float) -> float
