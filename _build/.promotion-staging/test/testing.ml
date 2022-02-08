open! Core_kernel
open! Multi_uttt
open! Notty

let%expect_test "" =
  let board = Board.create () in
  let turn = Player.O in
  let model = { Model.board; turn } in
  let image = Model.render model in
  let b = Buffer.create 0 in
  Notty.Render.to_buffer b Cap.dumb (0, 0) (80, 24) image;
  print_endline (Buffer.contents b);
  [%expect
    {|
    - - -  - - -  - - -
    - - -  - - -  - - -
    - - -  - - -  - - -

    - - -  - - -  - - -
    - - -  - - -  - - -
    - - -  - - -  - - -

    - - -  - - -  - - -
    - - -  - - -  - - -
    - - -  - - -  - - - |}];
  printf "%s" (Board.to_string board);
  [%expect
    {|
    - - -  - - -  - - -
    - - -  - - -  - - -
    - - -  - - -  - - -

    - - -  - - -  - - -
    - - -  - - -  - - -
    - - -  - - -  - - -

    - - -  - - -  - - -
    - - -  - - -  - - -
    - - -  - - -  - - - |}];
  print_s [%sexp (3. ** 3. : float)];
  [%expect {| 27 |}]
;;
