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

// Four-row procedural blocker generation. Row timing is derived from world
// distance so obstacle density remains stable as scrolling accelerates.
blocker_generation_enabled = true;
blocker_spawn_timer = 0.30;
blocker_spawn_buffer = 64;
blocker_cluster_spacing_min = 315;
blocker_cluster_spacing_max = 380;
blocker_transition_spacing_min = 570;
blocker_transition_spacing_max = 640;
blocker_distance_to_next_row = 640;
blocker_patterns = scr_blocker_pattern_data();
blocker_pattern_row = 0;
blocker_previous_row_mask = 0;
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
debug_manual_lockon = false;
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
lockon_last_ufo_side = 0;
lockon_spawn_timer = 2;
lockon_cooldown_min = 4;
lockon_cooldown_max = 6.5;

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
