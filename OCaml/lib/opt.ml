open! Core_kernel

type t =
  | Min
  | Max
[@@deriving compare, equal]
