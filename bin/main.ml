(* Abre o módulo Raylib no escopo global para não precisar prefixar tudo com 'Raylib.' *)
open Raylib

(* =========================================================================
   1. MODELO DE DADOS (Types / State)
   Estruturas imutáveis que definem todo o estado da aplicação.
   ========================================================================= *)

(* O jogador possui uma posição atual no mundo e um alvo para onde está se movendo *)
type player = { 
  pos : Vector2.t; 
  target : Vector2.t 
}

(* O estado global do jogo reúne todas as entidades e pontuações do frame atual *)
type game_state = { 
  player : player; 
  score : int 
}

(* Representa as intenções capturadas do jogador neste frame.
   Usa 'option' porque o clique pode ter acontecido (Some) ou não (None). *)
type input = { 
  new_target : Vector2.t option 
}

(* =========================================================================
   2. ENTRADA (I/O)
   Lê os periféricos via Raylib e traduz eventos em dados puros do tipo 'input'.
   ========================================================================= *)
let read_inputs () =
  (* Detecta apenas o clique inicial do botão esquerdo do mouse *)
  if is_mouse_button_pressed MouseButton.Left then
    (* Subtrai 16.0 para que o centro do quadrado (32x32) fique sob o cursor *)
    let mx = float_of_int (get_mouse_x ()) -. 16.0 in
    let my = float_of_int (get_mouse_y ()) -. 16.0 in
    (* Cria o vetor e o embrulha no construtor 'Some' *)
    { new_target = Some (Vector2.create mx my) }
  else 
    (* Nenhum clique neste frame *)
    { new_target = None }

(* =========================================================================
   3. ATUALIZAÇÃO / LÓGICA PURA (Update)
   Funções matemáticas puras: recebem dados antigos e retornam novos dados.
   Não realizam I/O e não alteram variáveis por referência.
   ========================================================================= *)

(* Atualiza a física do jogador com base nos comandos e no tempo decorrido *)
let update_player (p : player) (inp : input) (dt : float) : player =
  let speed = 250.0 in
  
  (* Desempacota o clique opcional:
     - Se clicou (Some t): adota 't' como novo alvo.
     - Se não clicou (None): mantém o alvo anterior (p.target). *)
  let target = match inp.new_target with Some t -> t | None -> p.target in
  
  (* Desloca o vetor em direção ao alvo respeitando o limite do frame (speed * dt) *)
  let next_pos = Vector2.move_towards p.pos target (speed *. dt) in
  
  (* Retorna uma nova estrutura imutável de player *)
  { pos = next_pos; target }

(* Função central de atualização: orquestra todos os subsistemas do jogo *)
let update (state : game_state) (inp : input) (dt : float) : game_state =
  { 
    player = update_player state.player inp dt; 
    score = state.score + 1 (* Incrementa a pontuação a cada frame *)
  }

(* =========================================================================
   4. RENDERIZAÇÃO (View / Draw)
   Consome o estado imutável apenas para desenhar na tela via OpenGL.
   ========================================================================= *)
let draw (state : game_state) =
  begin_drawing ();
  clear_background Color.raywhite;

  (* Converte as coordenadas float do vetor em inteiros exigidos pelo draw_rectangle *)
  draw_rectangle
    (int_of_float (Vector2.x state.player.pos))
    (int_of_float (Vector2.y state.player.pos))
    32 32 Color.blue;

  (* Exibe o placar no canto superior esquerdo *)
  draw_text (Printf.sprintf "Score: %d" state.score) 12 12 20 Color.darkgray;
  
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
    let dt = get_frame_time () in           (* Tempo do último frame em segundos *)
    let inp = read_inputs () in             (* 1. Coleta entradas *)
    let next_state = update state inp dt in (* 2. Calcula o novo estado *)
    draw next_state;                        (* 3. Renderiza o novo estado *)
    game_loop next_state                    (* 4. Reinicia o ciclo com o novo estado *)

(* =========================================================================
   6. PONTO DE ENTRADA (Initialization & Cleanup)
   Configura a janela do SO, aloca recursos e inicia o loop com o estado base.
   ========================================================================= *)
let () =
  init_window 800 600 "Meu Jogo em OCaml Raylib";
  set_target_fps 60; (* Trava a taxa de quadros para suavizar o delta time *)

  (* Define as condições iniciais do jogo (posicionado no centro 400x300) *)
  let initial_state =
    {
      player =
        {
          pos = Vector2.create (400.0 -. 16.0) (300.0 -. 16.0);
          target = Vector2.create (400.0 -. 16.0) (300.0 -. 16.0);
        };
      score = 0;
    }
  in

  (* Inicia o ciclo do jogo *)
  game_loop initial_state;

  (* Desaloca o contexto OpenGL e fecha a janela ao sair do loop *)
  close_window ()