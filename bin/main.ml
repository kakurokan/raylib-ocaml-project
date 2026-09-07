open Raylib

(* Dimensões da janela como constantes globais *)
let screen_width = 800
let screen_height = 600

(* =========================================================================
   1. MODELO DE DADOS (Types / State)
   ========================================================================= *)

type player = { position : Vector2.t; velocity : Vector2.t; radius : float }
type game_state = { player : player; click_origin : Vector2.t option }
type input = { drag_impulse : Vector2.t option }

(* =========================================================================
   2. ENTRADA (I/O)
   ========================================================================= *)

let read_input (state : game_state) =
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

(* =========================================================================
   3. ATUALIZAÇÃO / LÓGICA PURA (Update)
   ========================================================================= *)

let handle_wall_collisions (pos : Vector2.t) (vel : Vector2.t) (r : float)
    (w : float) (h : float) =
  let bounce = 0.75 in

  let x = Vector2.x pos in
  let y = Vector2.y pos in
  let vx = Vector2.x vel in
  let vy = Vector2.y vel in

  (* Colisão horizontal: Esquerda ou Direita *)
  let new_x, new_vx =
    if x -. r < 0.0 then (r, -.vx *. bounce)
    else if x +. r > w then (w -. r, -.vx *. bounce)
    else (x, vx)
  in

  (* Colisão vertical: Teto ou Chão *)
  let new_y, new_vy =
    if y -. r < 0.0 then (r, -.vy *. bounce)
    else if y +. r > h then (h -. r, -.vy *. bounce)
    else (y, vy)
  in

  (Vector2.create new_x new_y, Vector2.create new_vx new_vy)

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

  let friction_per_second = 0.05 in
  let decay = friction_per_second ** dt in
  let new_velocity = Vector2.scale vel_with_impulse decay in

  (* Usa float_of_int para passar as dimensões como float *)
  let final_pos, final_vel =
    handle_wall_collisions new_position new_velocity p.radius
      (float_of_int screen_width)
      (float_of_int screen_height)
  in

  { position = final_pos; velocity = final_vel; radius = p.radius }

let update (state : game_state) (new_origin : Vector2.t option) (inp : input)
    (dt : float) : game_state =
  { player = update_player state.player inp dt; click_origin = new_origin }

(* =========================================================================
   4. RENDERIZAÇÃO (View / Draw)
   ========================================================================= *)

let draw (state : game_state) =
  begin_drawing ();
  clear_background Color.raywhite;

  draw_circle_v state.player.position state.player.radius Color.red;

  (match state.click_origin with
  | Some origin when is_mouse_button_down MouseButton.Left ->
      draw_line_v origin (get_mouse_position ()) Color.gray
  | _ -> ());

  end_drawing ()

(* =========================================================================
   5. LOOP PRINCIPAL (Game Loop)
   ========================================================================= *)

let rec game_loop (state : game_state) =
  if window_should_close () then ()
  else
    let dt = get_frame_time () in
    let new_origin, inp = read_input state in
    let next_state = update state new_origin inp dt in
    draw next_state;
    game_loop next_state

(* =========================================================================
   6. PONTO DE ENTRADA (Initialization & Cleanup)
   ========================================================================= *)

let () =
  init_window screen_width screen_height "Meu Jogo em OCaml Raylib";
  set_target_fps 60;

  let initial_state =
    {
      player =
        {
          position =
            Vector2.create
              (float_of_int screen_width /. 2.0)
              (float_of_int screen_height /. 2.0);
          velocity = Vector2.create 0.0 0.0;
          radius = 16.0;
        };
      click_origin = None;
    }
  in

  game_loop initial_state;
  close_window ()
