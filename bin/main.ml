open Raylib

(* =========================================================================
   CONFIGURAÇÕES GLOBAIS
   ========================================================================= *)

let screen_width = 800
let screen_height = 600

(* =========================================================================
   1. MODELO DE DADOS (Model / State)
   Estruturas de dados imutáveis que representam o estado completo da aplicação.
   ========================================================================= *)

(* Entidade controlada pelo usuário via mecânica de estilingue *)
type player = { position : Vector2.t; velocity : Vector2.t; radius : float }

(* Entidade reativa; inicia imóvel ('velocity = None') e reage a colisões *)
type enemy = {
  position : Vector2.t;
  velocity : Vector2.t option;
  health : int;
  radius : float;
}

(* Estado global imutável propagado quadro a quadro pelo loop principal *)
type game_state = {
  player : player;
  click_origin : Vector2.t option; (* Coordenada inicial do arrasto para mira *)
  enemies : enemy list;
}

(* Intenções capturadas do jogador no frame atual *)
type input = {
  drag_impulse : Vector2.t option;
      (* Impulso elástico gerado ao soltar o clique *)
}

(* =========================================================================
   2. ENTRADA (Input / IO)
   Efetua a leitura de periféricos e traduz eventos brutos em dados puros.
   ========================================================================= *)

let read_input (state : game_state) =
  let mouse_pos = get_mouse_position () in

  (* Inicia o arrasto se o botão esquerdo for pressionado sobre o jogador *)
  let new_origin =
    if is_mouse_button_pressed MouseButton.Left then
      if
        check_collision_point_circle mouse_pos state.player.position
          state.player.radius
      then Some mouse_pos
      else state.click_origin
    else state.click_origin
  in

  (* Ao soltar o clique, gera um vetor de impulso em direção oposta ao arrasto *)
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
   3. ATUALIZAÇÃO E FÍSICA (Update / Pure Logic)
   Funções matemáticas puras sem efeitos colaterais.
   ========================================================================= *)

(* Trata os limites da janela: inverte velocidade com restituição e corrige penetração *)
let handle_wall_collisions (pos : Vector2.t) (vel : Vector2.t) (r : float)
    (w : float) (h : float) =
  let bounce = 0.75 in
  (* Coeficiente de restituição (perda parcial de energia) *)

  let x = Vector2.x pos in
  let y = Vector2.y pos in
  let vx = Vector2.x vel in
  let vy = Vector2.y vel in

  (* Colisão horizontal: bordas esquerda e direita *)
  let new_x, new_vx =
    if x -. r < 0.0 then (r, -.vx *. bounce)
    else if x +. r > w then (w -. r, -.vx *. bounce)
    else (x, vx)
  in

  (* Colisão vertical: bordas superior e inferior *)
  let new_y, new_vy =
    if y -. r < 0.0 then (r, -.vy *. bounce)
    else if y +. r > h then (h -. r, -.vy *. bounce)
    else (y, vy)
  in

  (Vector2.create new_x new_y, Vector2.create new_vx new_vy)

(* Trata colisão entre jogador e inimigo: separação posicional, impulso e recuo *)
let handle_player_enemy_collisions (enemy : enemy) (player : player) :
    enemy * player =
  if
    check_collision_circles player.position player.radius enemy.position
      enemy.radius
  then
    let diff = Vector2.subtract enemy.position player.position in
    let dist = Vector2.length diff in

    (* Evita divisão por zero caso as posições coincidam exatamente *)
    if dist > 0.0001 then
      let dir = Vector2.scale diff (1.0 /. dist) in

      (* Correção posicional imediata: distribui a sobreposição meio a meio para evitar travamento *)
      let overlap = player.radius +. enemy.radius -. dist in
      let separation = Vector2.scale dir (overlap *. 0.5) in
      let separated_enemy_pos = Vector2.add enemy.position separation in
      let separated_player_pos = Vector2.subtract player.position separation in

      (* Transfere momento do impacto para o inimigo *)
      let player_speed = Vector2.length player.velocity in
      let push_force = Float.max player_speed 250.0 in
      let impulse = Vector2.scale dir push_force in

      let next_enemy =
        {
          enemy with
          position = separated_enemy_pos;
          velocity = Some impulse;
          health = enemy.health - 1;
        }
      in

      (* Aplica recuo proporcional no jogador (ação e reação) *)
      let recoil = Vector2.scale dir (-0.5 *. push_force) in
      let next_player =
        { player with position = separated_player_pos; velocity = recoil }
      in

      (next_enemy, next_player)
    else (enemy, player)
  else (enemy, player)

(* Atualiza cinemática, fricção exponencial e limites de tela do jogador *)
let update_player (p : player) (inp : input) (dt : float) : player =
  (* Aplica força de estilingue caso o mouse tenha sido solto neste frame *)
  let vel_with_impulse =
    match inp.drag_impulse with
    | Some impulse ->
        let scaled_impulse = Vector2.scale impulse 5.0 in
        Vector2.add p.velocity scaled_impulse
    | None -> p.velocity
  in

  (* Integração temporal de Euler: pos = pos + (vel * dt) *)
  let frame_displacement = Vector2.scale vel_with_impulse dt in
  let new_position = Vector2.add p.position frame_displacement in

  (* Amortecimento por fricção independente da taxa de quadros *)
  let friction_per_second = 0.05 in
  let decay = friction_per_second ** dt in
  let new_velocity = Vector2.scale vel_with_impulse decay in

  (* Resolução contra as quatro paredes *)
  let final_pos, final_vel =
    handle_wall_collisions new_position new_velocity p.radius
      (float_of_int screen_width)
      (float_of_int screen_height)
  in

  { position = final_pos; velocity = final_vel; radius = p.radius }

(* Atualiza cinemática do inimigo; permanece inerte se a velocidade for 'None' *)
let update_enemy (enemy : enemy) (dt : float) : enemy =
  match enemy.velocity with
  | None -> enemy
  | Some vel ->
      (* Deslocamento linear *)
      let frame_displacement = Vector2.scale vel dt in
      let new_position = Vector2.add enemy.position frame_displacement in

      (* Fricção no solo *)
      let friction_per_second = 0.08 in
      let decay = friction_per_second ** dt in
      let new_velocity = Vector2.scale vel decay in

      (* Quique nas paredes *)
      let final_pos, final_vel =
        handle_wall_collisions new_position new_velocity enemy.radius
          (float_of_int screen_width)
          (float_of_int screen_height)
      in

      (* Repouso: cancela a velocidade quando ela fica residual *)
      if Vector2.length final_vel < 1.0 then
        { enemy with position = final_pos; velocity = None }
      else { enemy with position = final_pos; velocity = Some final_vel }

(* Orquestrador do estado global: integra entidades e resolve colisões *)
let update (state : game_state) (new_origin : Vector2.t option) (inp : input)
    (dt : float) : game_state =
  (* 1. Move o jogador primeiro *)
  let moved_player = update_player state.player inp dt in

  (* 2. Resolve colisões jogador-inimigos acumulando as alterações em ambas as partes *)
  let next_player, updated_enemies =
    List.fold_right
      (fun e (cur_player, acc_enemies) ->
        let e', p' = handle_player_enemy_collisions e cur_player in
        (p', e' :: acc_enemies))
      state.enemies (moved_player, [])
  in

  (* 3. Atualiza a física de cada inimigo individualmente *)
  let next_enemies = List.map (fun e -> update_enemy e dt) updated_enemies in

  { player = next_player; click_origin = new_origin; enemies = next_enemies }

(* =========================================================================
   4. RENDERIZAÇÃO (View / Draw)
   Consome o estado de forma somente leitura para desenhar na tela.
   ========================================================================= *)

let draw (state : game_state) =
  begin_drawing ();
  clear_background Color.raywhite;

  (* Jogador *)
  draw_circle_v state.player.position state.player.radius Color.red;

  (* Inimigos *)
  List.iter
    (fun e -> draw_circle_v e.position e.radius Color.blue)
    state.enemies;

  (* Traço guia do estilingue durante o arrasto *)
  (match state.click_origin with
  | Some origin when is_mouse_button_down MouseButton.Left ->
      draw_line_v origin (get_mouse_position ()) Color.gray
  | _ -> ());

  end_drawing ()

(* =========================================================================
   5. LOOP PRINCIPAL (Game Loop)
   Loop infinito por recursão em cauda garantindo consumo de pilha constante.
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
   Inicialização do contexto da janela Raylib e alocação do estado inicial.
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
      enemies =
        [
          {
            position =
              Vector2.create
                ((float_of_int screen_width /. 2.0) +. 20.0)
                ((float_of_int screen_height /. 2.0) +. 20.0);
            velocity = None;
            health = 10;
            radius = 16.0;
          };
        ];
    }
  in

  game_loop initial_state;
  close_window ()
