open Raylib

type player = {
  position : Vector2.t;
  velocity : Vector2.t;
  radius : float;
}

type enemy = {
  position : Vector2.t;
  velocity : Vector2.t option;
  health : int;
  radius : float;
}

type game_state = {
  player : player;
  click_origin : Vector2.t option;
  enemies : enemy list;
}

type input = {
  drag_impulse : Vector2.t option;
}