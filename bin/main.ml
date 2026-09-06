open Raylib

type player = { x : float; y : float; hp : int }
type game_state = { player : player; score : int }
type input = { dx : float; dy : float }

let read_inputs () =
  let dx =
    (if Raylib.is_key_down Raylib.Key.Right then 1.0 else 0.0)
    -. if Raylib.is_key_down Raylib.Key.Left then 1.0 else 0.0
  in
  let dy =
    (if Raylib.is_key_down Raylib.Key.Down then 1.0 else 0.0)
    -. if Raylib.is_key_down Raylib.Key.Up then 1.0 else 0.0
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
  Raylib.begin_drawing ();
  Raylib.clear_background Raylib.Color.raywhite;

  Raylib.draw_rectangle
    (int_of_float state.player.x)
    (int_of_float state.player.y)
    32 32 Raylib.Color.blue;

  Raylib.draw_text
    (Printf.sprintf "Score: %d" state.score)
    12 12 20 Raylib.Color.darkgray;
  Raylib.end_drawing ()
