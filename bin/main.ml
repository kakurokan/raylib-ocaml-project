open Raylib

type state = {
  delta_x : float;
  frame_x : float;
  target_fps : int;
}

let screen_width = 800
let screen_height = 450
let speed = 10.0
let circle_radius = 32.0

let update_state (prev : state) : state =
  (* Ajusta o limite de FPS com a roda do mouse *)
  let wheel = get_mouse_wheel_move () in
  let target_fps =
    if wheel <> 0.0 then
      let next_fps = prev.target_fps + int_of_float wheel in
      let clamped_fps = max 0 next_fps in
      set_target_fps clamped_fps;
      clamped_fps
    else
      prev.target_fps
  in

  (* Atualiza posições *)
  let dt = get_frame_time () in
  let next_delta_x = prev.delta_x +. (dt *. 6.0 *. speed) in
  let next_frame_x = prev.frame_x +. (0.1 *. speed) in

  (* Reseta se sair da tela *)
  let next_delta_x = if next_delta_x > float_of_int screen_width then 0.0 else next_delta_x in
  let next_frame_x = if next_frame_x > float_of_int screen_width then 0.0 else next_frame_x in

  (* Tecla R reinicia as posições *)
  if is_key_pressed Key.R then
    { delta_x = 0.0; frame_x = 0.0; target_fps }
  else
    { delta_x = next_delta_x; frame_x = next_frame_x; target_fps }

let draw (s : state) =
  begin_drawing ();
  clear_background Color.raywhite;

  let y_delta = float_of_int screen_height /. 3.0 in
  let y_frame = float_of_int screen_height *. (2.0 /. 3.0) in

  (* Círculos *)
  draw_circle_v (Vector2.create s.delta_x y_delta) circle_radius Color.red;
  draw_circle_v (Vector2.create s.frame_x y_frame) circle_radius Color.blue;

  (* Textos informativos *)
  let fps_text =
    if s.target_fps <= 0 then
      Printf.sprintf "FPS: unlimited (%d)" (get_fps ())
    else
      Printf.sprintf "FPS: %d (target: %d)" (get_fps ()) s.target_fps
  in
  draw_text fps_text 10 10 20 Color.darkgray;
  draw_text (Printf.sprintf "Frame time: %02.02f ms" (get_frame_time () *. 1000.0)) 10 30 20 Color.darkgray;
  draw_text "Use the scroll wheel to change the fps limit, r to reset" 10 50 20 Color.darkgray;

  (* Legendas dos círculos *)
  draw_text "FUNC: x += GetFrameTime()*speed" 10 90 20 Color.red;
  draw_text "FUNC: x += speed" 10 240 20 Color.blue;

  end_drawing ()

let () =
  init_window screen_width screen_height "raylib [core] example - delta time";
  set_target_fps 60;

  let initial_state = {
    delta_x = 0.0;
    frame_x = 0.0;
    target_fps = 60;
  } in

  let rec game_loop (current_state : state) =
    if window_should_close () then ()
    else begin
      let next_state = update_state current_state in
      draw next_state;
      game_loop next_state
    end
  in

  game_loop initial_state;
  close_window ()