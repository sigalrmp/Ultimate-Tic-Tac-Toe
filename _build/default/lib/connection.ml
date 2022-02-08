open! Core_kernel
open! Notty_async
open! Async

type t =
  | Server of Rpc.Connection.t
  | Ai of
      { game : Ai_game.t
      ; actions : Action.t Pipe.Reader.t
      }
[@@derriving equal]
