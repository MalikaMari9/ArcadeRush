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

// Collectibles are generated along each validated blocker row, in the
// open corridor between this row and the previous row. All tuning is here.
ticket_active_max = 23;
ticket_rows_since_spawn = 0;
ticket_trail_start_y = -250;
ticket_trail_spacing = 120;
ticket_spawn_clearance = 14;
// Keep recent reward lanes varied without sacrificing reachable placements.
ticket_lane_heat = [0, 0, 0, 0];
ticket_last_lane = -1;
ticket_last_style = -1;

// First power-up arrives after ~7-11 seconds at the starting scroll speed.
// Later opportunities average ~12 seconds apart, independent of frame rate.
// Only one uncollected power-up may be on screen at a time.
powerup_distance_remaining = random_range(1900, 2600);
powerup_spacing_min = 3300;
powerup_spacing_max = 4600;
powerup_active_max = 1;
powerup_last_kind = -1;
powerup_spawn_y = 85;
powerup_sprite_scale = 0.64;
powerup_clearance = 20;

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
// Switch the protected route between halves of the screen. Without this,
// physically wide blockers make the originally random walk settle rightward.
blocker_route_target_lane = irandom(3);
blocker_route_dwell = 0;
blocker_route_dwell_goal = irandom_range(4, 8);

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
