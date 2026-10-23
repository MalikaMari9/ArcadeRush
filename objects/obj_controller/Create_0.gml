randomise();

// Starting values for the shared downward world scroll.
// These are tuning values and should be adjusted through playtesting.
world_scroll_speed = 250;
world_scroll_acceleration = 5;
world_scroll_speed_max = 350;

world_scroll_delta = 0;
distance_travelled = 0;

// Placeholder run counters. Distance is stored in world pixels and converted
// only for display so gameplay systems retain the precise progress value.
distance_pixels_per_metre = 100;
run_tickets = 0;

// A lethal player hit first shows the front-facing hurt animation. The
// dedicated obj_gameover takes ownership after this short delay.
game_over_wait_timer = 0;
game_over_hurt_duration = 0.80;

// Ticket opportunities are evaluated per generated distance section. These
// are playtesting values, not GDD-mandated frequencies.
ticket_opportunity_chance_early = 0.65;
ticket_opportunity_chance_mid = 0.70;
ticket_opportunity_chance_late = 0.75;
ticket_distance_to_next_opportunity = 360;
ticket_opportunity_spacing_min = 500;
ticket_opportunity_spacing_max = 720;
ticket_spawn_buffer = 48;
ticket_safe_clearance_early = 30;
ticket_safe_clearance_late = 8;
ticket_placement_attempts = 12;
ticket_active_max = 8;
ticket_debug_logging = false;

// Continuous distance-driven rows. The minimum gap is larger than the
// tallest blocker plus the largest player collision mask, and one physically
// passable lane is carried safely between consecutive rows.
blocker_generation_enabled = true;
blocker_spawn_buffer = 64;
blocker_row_spacing_min = 625;
blocker_row_spacing_max = 700;
blocker_distance_remaining = 250;
blocker_previous_row_mask = 0;
blocker_safe_lane = irandom(3);
blocker_rows_spawned = 0;

// Four measured lanes between the margins.
blocker_lane_left = 124;
blocker_lane_width = 208;
blocker_lane_count = 4;

// Manual encounter controls (U = UFO, K = Key Pusher).
debug_manual_lockon = false;

// Current control-area edges created by the side margins in rm_gameRoom.
blocker_spawn_left = 128;
blocker_spawn_right = 960;

// UFO and Key Pusher preferentially alternate and never overlap each other.
// A support hazard can delay a due encounter for at most two seconds.
lockon_last_ufo_side = 0;
lockon_last_type = 0;
lockon_spawn_timer = 3.5;
lockon_cooldown_min = 7;
lockon_cooldown_max = 9;
lockon_support_wait = 0;
lockon_support_wait_limit = 2;

// Autonomous coin tower: at most one active tower at a time.
coin_spawn_timer = 5;
coin_spawn_cooldown_min = 11;
coin_spawn_cooldown_max = 17;
coin_spawn_buffer = 64;

// Screen-fixed walking duck encounter. It joins the automatic hazard pool
// only after the run has had time to reach its harder phase.
duck_spawn_timer = 50;
duck_spawn_cooldown_min = 17;
duck_spawn_cooldown_max = 24;
