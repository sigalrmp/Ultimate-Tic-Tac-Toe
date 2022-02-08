open! Core_kernel

type t =
  { pos : Ultimate_position.t
  ; restriction : Position.t option
  }

let create_init () =
  { pos = Ultimate_position.create 0 0 0 0; restriction = None }
;;

let valid (t : t) =
  match t.restriction with
  | None -> true
  | Some r ->
    let row, col = Ultimate_position.board t.pos in
    let r_row, r_col = r in
    equal row r_row && equal col r_col
;;

let up t =
  let big_row, lil_row =
    match Ultimate_position.big_row t.pos, Ultimate_position.lil_row t.pos with
    | 0, 0 -> 0, 0
    | b, 0 -> b - 1, 2
    | b, l -> b, l - 1
  in
  let new_pos =
    Ultimate_position.create
      big_row
      (Ultimate_position.big_col t.pos)
      lil_row
      (Ultimate_position.lil_col t.pos)
  in
  let t' = { t with pos = new_pos } in
  if valid t' then t' else t
;;

let left t =
  let big_col, lil_col =
    match Ultimate_position.big_col t.pos, Ultimate_position.lil_col t.pos with
    | 0, 0 -> 0, 0
    | b, 0 -> b - 1, 2
    | b, l -> b, l - 1
  in
  let new_pos =
    Ultimate_position.create
      (Ultimate_position.big_row t.pos)
      big_col
      (Ultimate_position.lil_row t.pos)
      lil_col
  in
  let t' = { t with pos = new_pos } in
  if valid t' then t' else t
;;

let down t =
  let big_row, lil_row =
    match Ultimate_position.big_row t.pos, Ultimate_position.lil_row t.pos with
    | 2, 2 -> 2, 2
    | b, 2 -> b + 1, 0
    | b, l -> b, l + 1
  in
  let new_pos =
    Ultimate_position.create
      big_row
      (Ultimate_position.big_col t.pos)
      lil_row
      (Ultimate_position.lil_col t.pos)
  in
  let t' = { t with pos = new_pos } in
  if valid t' then t' else t
;;

let right t =
  let big_col, lil_col =
    match Ultimate_position.big_col t.pos, Ultimate_position.lil_col t.pos with
    | 2, 2 -> 2, 2
    | b, 2 -> b + 1, 0
    | b, l -> b, l + 1
  in
  let new_pos =
    Ultimate_position.create
      (Ultimate_position.big_row t.pos)
      big_col
      (Ultimate_position.lil_row t.pos)
      lil_col
  in
  let t' = { t with pos = new_pos } in
  if valid t' then t' else t
;;

let to_grid t =
  let br = Ultimate_position.big_row t.pos in
  let lr = Ultimate_position.lil_row t.pos in
  let bc = Ultimate_position.big_col t.pos in
  let lc = Ultimate_position.lil_col t.pos in
  let x = (7 * bc) + (2 * lc) in
  let y = (4 * br) + lr in
  x, y
;;
