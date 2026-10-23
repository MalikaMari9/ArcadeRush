// Movement speed in pixels per second.
move_speed = 500;

// Temporary protection/life state. Damage behavior will be added later.
player_lives = 3;
player_dead = false;
player_last_damage_cause = PlayerDamageCause.UNKNOWN;

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

// Ticket Magnet power-up. Duplicate pickups refresh this duration instead of
// stacking a second attraction effect.
ticket_magnet_timer = 0;
ticket_magnet_duration = 8;
ticket_magnet_radius = 600;
ticket_magnet_visual_frame = 0;
ticket_magnet_visual_time = 0;

// Double Ticket power-up. It affects ticket currency only.
ticket_double_timer = 0;
ticket_double_duration = 8;
ticket_double_visual_frame = 0;
ticket_double_visual_time = 0;

// One-hit shield. It expires naturally if it is not used in time.
powerup_shield_timer = 0;
powerup_shield_duration = 10;
powerup_shield_visual_time = 0;
