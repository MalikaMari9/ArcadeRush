// Movement speed in pixels per second.
move_speed = 500;

// Temporary protection/life state. Damage behavior will be added later.
player_lives = 3;

// The runner always faces forward into the scrolling arcade.
player_horizontal_facing = 1;
player_refresh_appearance(true);

// Set by hazards that temporarily take control of the player.
ufo_captured = false;
ufo_captor = noone;
scalper_captured = false;

// Shared protection used after hazards return control to the player.
invulnerable = false;
invulnerability_timer = 0;
invulnerability_duration = 1.75;
invulnerability_blink_interval = 0.1;
invulnerability_blink_timer = 0;
phase_through_obstacles = false;
image_alpha = 1;
