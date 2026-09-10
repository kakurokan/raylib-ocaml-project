open Raylib
open Game_lib

let rec game_loop (state : Types.game_state) =
  if window_should_close () then ()
  else
    let dt = get_frame_time () in
    let new_origin, inp = Input.read state in
    let next_state = Update.step state new_origin inp dt in
    View.render next_state;
    game_loop next_state

let () =
  init_window Config.screen_width Config.screen_height "Meu Jogo em OCaml Raylib";
  set_target_fps Config.target_fps;

  let initial_state : Types.game_state =
    {
      player =
        {
          position =
            Vector2.create
              (Config.screen_width_f /. 2.0)
              (Config.screen_height_f /. 2.0);
          velocity = Vector2.create 0.0 0.0;
          radius = 16.0;
        };
      click_origin = None;
      enemies =
        [
          {
            position =
              Vector2.create
                ((Config.screen_width_f /. 2.0) +. 40.0)
                ((Config.screen_height_f /. 2.0) +. 40.0);
            velocity = None;
            health = 5;
            radius = 16.0;
          };
          {
            position =
              Vector2.create
                ((Config.screen_width_f /. 2.0) -. 100.0)
                ((Config.screen_height_f /. 2.0) -. 80.0);
            velocity = None;
            health = 3;
            radius = 14.0;
          };
        ];
    }
  in

  game_loop initial_state;
  close_window ()