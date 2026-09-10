open Raylib
open Types

let draw_enemy (e : enemy) =
  draw_circle_v e.position e.radius Color.blue;

  (*Draw the cracks segments*)
  List.iter 
    (fun (p1_offset, p2_offset) ->
      let p1 = Vector2.add e.position p1_offset in
      let p2 = Vector2.add e.position p2_offset in
      draw_line_ex p1 p2 2.0 Color.black)
      e.cracks

  


let render (state : game_state) : unit =
  begin_drawing ();
  clear_background Color.raywhite;

  (* Jogador *)
  draw_circle_v state.player.position state.player.radius Color.red;

  (* Inimigos e texto de vida *)
  List.iter draw_enemy state.enemies;

  (* Mira do estilingue *)
  (match state.click_origin with
  | Some origin when is_mouse_button_down MouseButton.Left ->
      draw_line_v origin (get_mouse_position ()) Color.gray
  | _ -> ());

  end_drawing ()