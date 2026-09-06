open Raylib

type player = { x : float; y : float; hp : int }
type game_state = { player : player; score : int }
type input = { dx : float; dy : float }

let read_inputs () =
  let dx =
    (if is_key_down Key.Right then 1.0 else 0.0)
    -. (if is_key_down Key.Left then 1.0 else 0.0)
  in
  let dy =
    (if is_key_down Key.Down then 1.0 else 0.0)
    -. (if is_key_down Key.Up then 1.0 else 0.0)
  in
  { dx; dy }

let update_player (p : player) (inp : input) (dt : float) : player =
  let speed = 250.0 in
  {
    p with
    x = p.x +. (inp.dx *. speed *. dt);
    y = p.y +. (inp.dy *. speed *. dt);
  }

let update (state : game_state) (inp : input) (dt : float) : game_state =
  { player = update_player state.player inp dt; score = state.score + 1 }

let draw (state : game_state) =
  begin_drawing ();
  clear_background Color.raywhite;

  draw_rectangle
    (int_of_float state.player.x)
    (int_of_float state.player.y)
    32 32 Color.blue;

  draw_text
    (Printf.sprintf "Score: %d" state.score)
    12 12 20 Color.darkgray;
  end_drawing ()

let rec game_loop (state : game_state) =
  if window_should_close () then ()
  else
    let dt = get_frame_time () in
    let inp = read_inputs () in
    let next_state = update state inp dt in
    draw next_state;
    game_loop next_state

(* --- Ponto de entrada do programa --- *)
let () =
  init_window 800 600 "Meu Jogo em OCaml Raylib";
  set_target_fps 60;

  let initial_state = {
    player = { x = 400.0 -. 16.0; y = 300.0 -. 16.0; hp = 100 };
    score = 0;
  } in

  game_loop initial_state;

  close_window ()