open Raylib
open Types

let read (state : game_state) : Vector2.t option * input =
  let mouse_pos = get_mouse_position () in

  let new_origin =
    if is_mouse_button_pressed MouseButton.Left then
      if
        check_collision_point_circle mouse_pos state.player.position
          state.player.radius
      then Some mouse_pos
      else state.click_origin
    else state.click_origin
  in

  let impulse, final_origin =
    if is_mouse_button_released MouseButton.Left then
      match new_origin with
      | Some origin ->
          let diff = Vector2.subtract mouse_pos origin in
          let negate = Vector2.negate diff in
          (Some negate, None)
      | None -> (None, None)
    else (None, new_origin)
  in

  (final_origin, { drag_impulse = impulse })