open Raylib
open Types

let render (state : game_state) : unit =
  begin_drawing ();
  clear_background Color.raywhite;

  (* Jogador *)
  draw_circle_v state.player.position state.player.radius Color.red;

  (* Inimigos e texto de vida *)
  List.iter
    (fun e ->
      draw_circle_v e.position e.radius Color.blue;
      let text = string_of_int e.health in
      let tx = int_of_float (Vector2.x e.position) - 4 in
      let ty = int_of_float (Vector2.y e.position) - 8 in
      draw_text text tx ty 14 Color.white)
    state.enemies;

  (* Mira do estilingue *)
  (match state.click_origin with
  | Some origin when is_mouse_button_down MouseButton.Left ->
      draw_line_v origin (get_mouse_position ()) Color.gray
  | _ -> ());

  end_drawing ()