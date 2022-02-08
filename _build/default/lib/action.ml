open! Core

type t =
  | Move of
      { player : Player.t
      ; move : Ultimate_position.t
      }
[@@deriving bin_io]
