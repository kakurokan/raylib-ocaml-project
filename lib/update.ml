open Raylib
open Types

(*Generate a segment on the oppesite direction of impact*)
let generate_crack (impact_dir : Vector2.t) (radius : float) : crack =
  (*Where the player hit*)
  let start_offset = Vector2.scale (Vector2.negate impact_dir) radius in

  (*Final point*)
  let jitter_x = Random.float 10.0 -. 5.0 in
  let jitter_y = Random.float 10.0 -. 5.0 in
  let end_offset =
    Vector2.create
      ((Vector2.x start_offset *. 0.2) +. jitter_x)
      ((Vector2.y start_offset *. 0.2) +. jitter_y)
  in
  (start_offset, end_offset)

let resolve_collision (enemy : enemy) (player : player) : enemy * player =
  if
    check_collision_circles player.position player.radius enemy.position
      enemy.radius
  then
    let diff = Vector2.subtract enemy.position player.position in
    let dist = Vector2.length diff in

    if dist > 0.0001 then
      let dir = Vector2.scale diff (1.0 /. dist) in

      (* Separação geométrica posicional *)
      let overlap = player.radius +. enemy.radius -. dist in
      let separation = Vector2.scale dir (overlap *. 0.5) in
      let separated_enemy_pos = Vector2.add enemy.position separation in
      let separated_player_pos = Vector2.subtract player.position separation in

      let player_speed = Vector2.length player.velocity in
      let push_force = Float.max player_speed 250.0 in
      let impulse = Vector2.scale dir push_force in

      (* Generate a crack *)
      let new_crack = generate_crack dir enemy.radius in

      let next_enemy =
        {
          enemy with
          position = separated_enemy_pos;
          velocity = Some impulse;
          health = enemy.health - 1;
          cracks = new_crack :: enemy.cracks;
        }
      in

      let recoil = Vector2.scale dir (-0.5 *. push_force) in
      let next_player =
        { player with position = separated_player_pos; velocity = recoil }
      in

      (next_enemy, next_player)
    else (enemy, player)
  else (enemy, player)

let update_player (p : player) (inp : input) (dt : float) : player =
  let vel_with_impulse =
    match inp.drag_impulse with
    | Some impulse ->
        let scaled_impulse = Vector2.scale impulse 5.0 in
        Vector2.add p.velocity scaled_impulse
    | None -> p.velocity
  in

  let frame_displacement = Vector2.scale vel_with_impulse dt in
  let new_position = Vector2.add p.position frame_displacement in
  let new_velocity = Physics.apply_friction vel_with_impulse dt 0.05 in

  let final_pos, final_vel =
    Physics.handle_wall_collisions new_position new_velocity p.radius
      Config.screen_width_f Config.screen_height_f
  in

  { position = final_pos; velocity = final_vel; radius = p.radius }

let update_enemy (enemy : enemy) (dt : float) : enemy =
  match enemy.velocity with
  | None -> enemy
  | Some vel ->
      let frame_displacement = Vector2.scale vel dt in
      let new_position = Vector2.add enemy.position frame_displacement in
      let new_velocity = Physics.apply_friction vel dt 0.08 in

      let final_pos, final_vel =
        Physics.handle_wall_collisions new_position new_velocity enemy.radius
          Config.screen_width_f Config.screen_height_f
      in

      if Vector2.length final_vel < 1.0 then
        { enemy with position = final_pos; velocity = None }
      else { enemy with position = final_pos; velocity = Some final_vel }

let step (state : game_state) (new_origin : Vector2.t option) (inp : input)
    (dt : float) : game_state =
  let moved_player = update_player state.player inp dt in

  let next_player, updated_enemies =
    List.fold_right
      (fun e (cur_player, acc_enemies) ->
        let e', p' = resolve_collision e cur_player in
        (p', e' :: acc_enemies))
      state.enemies (moved_player, [])
  in

  let next_enemies =
    updated_enemies
    |> List.map (fun e -> update_enemy e dt)
    |> List.filter (fun e -> e.health > 0)
  in

  { player = next_player; click_origin = new_origin; enemies = next_enemies }
