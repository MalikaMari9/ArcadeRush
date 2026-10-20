// Starting values for the shared downward world scroll.
// These are tuning values and should be adjusted through playtesting.
world_scroll_speed = 120;
world_scroll_acceleration = 4;
world_scroll_speed_max = 300;

world_scroll_delta = 0;
distance_travelled = 0;

// Placeholder run counters. Distance is stored in world pixels and converted
// only for display so gameplay systems retain the precise progress value.
distance_pixels_per_metre = 100;
score_per_metre = 10;
run_tickets = 0;

// Lightweight collectible-ticket scheduler. Ticket patterns and effects can
// replace this later without changing the shared ticket objects.
ticket_spawn_timer = 3;
ticket_spawn_cooldown_min = 4;
ticket_spawn_cooldown_max = 7;
ticket_spawn_retry = 0.75;
ticket_spawn_buffer = 24;
ticket_active_max = 8;

// Four-row procedural blocker generation. Row timing is derived from world
// distance so obstacle density remains stable as scrolling accelerates.
blocker_generation_enabled = true;
blocker_spawn_timer = 0.85;
blocker_spawn_buffer = 64;
blocker_row_spacing_min = 410;
blocker_row_spacing_max = 520;
blocker_patterns = scr_blocker_pattern_data();
blocker_pattern_row = 0;
blocker_current_pattern_id = -1;
blocker_recent_pattern_ids = [];
blocker_mirror_current_pattern = false;
blocker_reverse_current_pattern = false;
blocker_hazard_breathers = true;

// Four measured lanes between the margins.
blocker_lane_left = 124;
blocker_lane_width = 208;
blocker_lane_count = 4;

// Temporary hazard testing switches.
debug_manual_lockon = true;
debug_world_speed_step = 30;
debug_world_speed_min = 30;
debug_spawn_blockers = false;
blocker_spawn_attempts = 8;
blocker_spawn_interval_min = 1.4;
blocker_spawn_interval_max = 2.2;

// Current control-area edges created by the side margins in rm_gameRoom.
blocker_spawn_left = 128;
blocker_spawn_right = 960;

// UFO and Key Pusher share one scheduler and never overlap.
lockon_spawn_timer = 3;
lockon_cooldown_min = 10;
lockon_cooldown_max = 20;

// Autonomous coin tower: at most one active tower at a time.
coin_spawn_timer = 5;
coin_spawn_cooldown_min = 11;
coin_spawn_cooldown_max = 17;
coin_spawn_buffer = 64;

// Screen-fixed walking duck encounter.
duck_spawn_timer = 9;
duck_spawn_cooldown_min = 17;
duck_spawn_cooldown_max = 24;

randomise();
