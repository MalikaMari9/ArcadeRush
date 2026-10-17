// Starting values for the shared downward world scroll.
// These are tuning values and should be adjusted through playtesting.
world_scroll_speed = 120;
world_scroll_acceleration = 4;
world_scroll_speed_max = 300;

world_scroll_delta = 0;
distance_travelled = 0;

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

// Current control-area edges created by the side margins in rm_gameRoom.
blocker_spawn_left = 128;
blocker_spawn_right = 960;

// UFO and Key Pusher share one scheduler and never overlap.
lockon_spawn_timer = 3;
lockon_cooldown_min = 10;
lockon_cooldown_max = 20;

randomise();
