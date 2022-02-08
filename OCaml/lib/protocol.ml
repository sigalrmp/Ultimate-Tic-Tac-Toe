open! Core
open! Async

let default_port = 9999

let subscribe =
  Rpc.State_rpc.create
    ~name:"subscribe"
    ~bin_query:[%bin_type_class: string]
    ~bin_state:[%bin_type_class: Player.t]
    ~bin_update:[%bin_type_class: Action.t]
    ~bin_error:[%bin_type_class: Nothing.t]
    ~version:1
    ()
;;

let apply_action =
  Rpc.Rpc.create
    ~name:"apply_action"
    ~bin_query:[%bin_type_class: Action.t]
    ~bin_response:[%bin_type_class: unit]
    ~version:1
;;
