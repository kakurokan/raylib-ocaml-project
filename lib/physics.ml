open Raylib

let handle_wall_collisions (pos : Vector2.t) (vel : Vector2.t) (r : float)
    (w : float) (h : float) =
  let bounce = 0.75 in
  let x, y = (Vector2.x pos, Vector2.y pos) in
  let vx, vy = (Vector2.x vel, Vector2.y vel) in

  let new_x, new_vx =
    if x -. r < 0.0 then (r, -.vx *. bounce)
    else if x +. r > w then (w -. r, -.vx *. bounce)
    else (x, vx)
  in

  let new_y, new_vy =
    if y -. r < 0.0 then (r, -.vy *. bounce)
    else if y +. r > h then (h -. r, -.vy *. bounce)
    else (y, vy)
  in

  (Vector2.create new_x new_y, Vector2.create new_vx new_vy)

let apply_friction (vel : Vector2.t) (dt : float) (friction_per_sec : float) : Vector2.t =
  let decay = friction_per_sec ** dt in
  Vector2.scale vel decay