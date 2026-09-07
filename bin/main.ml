(* Abre o módulo Raylib no escopo global para não precisar prefixar tudo com 'Raylib.' *)
open Raylib

(* =========================================================================
   1. MODELO DE DADOS (Types / State)
   Estruturas imutáveis que definem todo o estado da aplicação.
   ========================================================================= *)

(* O jogador possui uma posição atual no mundo e um alvo para onde está se movendo *)
type player = { position : Vector2.t; velocity : Vector2.t; radius : float }

(* O estado global do jogo reúne todas as entidades e pontuações do frame atual *)
type game_state = { player : player; click_origin : Vector2.t option }

(* Representa as intenções capturadas do jogador neste frame.
   Usa 'option' porque o clique pode ter acontecido (Some) ou não (None). *)
type input = { drag_impulse : Vector2.t option }

(* =========================================================================
   2. ENTRADA (I/O)
   Lê os periféricos via Raylib e traduz eventos em dados puros do tipo 'input'.
   ========================================================================= *)
let read_input (state : game_state) =
  (* Detecta se o clique inicial atingiu o círculo do jogador *)
  let new_origin =
    if is_mouse_button_pressed MouseButton.Left then
      let mouse_pos = get_mouse_position () in

      if
        check_collision_point_circle mouse_pos state.player.position
          state.player.radius
      then Some mouse_pos
      else state.click_origin
    else state.click_origin
  in

  (* Quando solta o botão esquerdo: calcula o impulso baseado no estilingue *)
  let impulse, final_origin =
    if is_mouse_button_released MouseButton.Left then
      match new_origin with
      | Some origin ->
          let mouse_pos = get_mouse_position () in
          let diff = Vector2.subtract mouse_pos origin in
          let negate = Vector2.negate diff in
          (Some negate, None)
      | None -> (None, None)
    else (None, new_origin)
  in

  (final_origin, { drag_impulse = impulse })

(* =========================================================================
   3. ATUALIZAÇÃO / LÓGICA PURA (Update)
   Funções matemáticas puras: recebem dados antigos e retornam novos dados.
   Não realizam I/O e não alteram variáveis por referência.
   ========================================================================= *)

(* Atualiza a física do jogador com base nos comandos e no tempo decorrido *)
let update_player (p : player) (inp : input) (dt : float) : player =
  (* Aplica impulso de estilingue se o mouse foi solto neste frame: .05f *)
  let vel_with_impulse =
    match inp.drag_impulse with
    | Some impulse ->
        let scaled_impulse = Vector2.scale impulse 5.0 in
        Vector2.add p.velocity scaled_impulse
    | None -> p.velocity
  in

  (*Deslocamento baseado no tempo: pos + (vel * dt) *)
  let frame_displacement = Vector2.scale vel_with_impulse dt in
  let new_position = Vector2.add p.position frame_displacement in

  (* Aplica fricção na velocidade*)
  let friction_per_second = 0.05 in
  let decay = friction_per_second ** dt in
  let new_velocity = Vector2.scale vel_with_impulse decay in

  { position = new_position; velocity = new_velocity; radius = p.radius }

(* Função central de atualização: orquestra todos os subsistemas do jogo *)
let update (state : game_state) (new_origin : Vector2.t option) (inp : input)
    (dt : float) : game_state =
  { player = update_player state.player inp dt; click_origin = new_origin }

(* =========================================================================
   4. RENDERIZAÇÃO (View / Draw)
   Consome o estado imutável apenas para desenhar na tela via OpenGL.
   ========================================================================= *)
let draw (state : game_state) =
  begin_drawing ();
  clear_background Color.raywhite;

  (* Converte as coordenadas float do vetor em inteiros exigidos pelo draw_rectangle *)
  draw_circle_v state.player.position state.player.radius Color.red;

  (match state.click_origin with
  | Some origin when is_mouse_button_down MouseButton.Left ->
      draw_line_v origin (get_mouse_position ()) Color.gray
  | _ -> ());

  end_drawing ()

(* =========================================================================
   5. LOOP PRINCIPAL (Game Loop)
   Loop infinito implementado via recursão em cauda (Tail Call Optimization).
   Cada iteração consome o frame atual e passa o próximo estado como argumento.
   ========================================================================= *)
let rec game_loop (state : game_state) =
  (* Interrompe a recursão se o usuário fechou a janela ou apertou ESC *)
  if window_should_close () then ()
  else
    (* Tempo do último frame em segundos *)
    let dt = get_frame_time () in
    (* 1. Coleta entradas *)
    let new_origin, inp = read_input state in
    (* 2. Calcula o novo estado *)
    let next_state = update state new_origin inp dt in
    (* 3. Renderiza o novo estado *)
    draw next_state;
    (* 4. Reinicia o ciclo com o novo estado *)
    game_loop next_state

(* =========================================================================
   6. PONTO DE ENTRADA (Initialization & Cleanup)
   Configura a janela do SO, aloca recursos e inicia o loop com o estado base.
   ========================================================================= *)
let () =
  let width = 800 in
  let height = 600 in

  init_window width height "Meu Jogo em OCaml Raylib";
  set_target_fps 60;

  (* Trava a taxa de quadros para suavizar o delta time *)

  (* Define as condições iniciais do jogo (posicionado no centro 400x300) *)
  let initial_state =
    {
      player =
        {
          position =
            Vector2.create
              (float_of_int width /. 2.0)
              (float_of_int height /. 2.0);
          velocity = Vector2.create 0.0 0.0;
          radius = 10.0;
        };
      click_origin = None;
    }
  in

  (* Inicia o ciclo do jogo *)
  game_loop initial_state;

  (* Desaloca o contexto OpenGL e fecha a janela ao sair do loop *)
  close_window ()
