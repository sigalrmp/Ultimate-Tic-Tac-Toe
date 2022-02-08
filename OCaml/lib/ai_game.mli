open! Async

type ai_const =
  { depth : int
  ; player : Player.t
  }

type t =
  { ai : ai_const
  ; mutable model : Model.t
  ; writer : Action.t Pipe.Writer.t
  }

val subscribe : unit -> (t * Action.t Pipe.Reader.t) Deferred.t
val apply_action : t -> Action.t -> unit