// Starting values for the shared downward world scroll.
// These are tuning values and should be adjusted through playtesting.
world_scroll_speed = 120;
world_scroll_acceleration = 4;
world_scroll_speed_max = 300;

world_scroll_delta = 0;
distance_travelled = 0;

// Temporary random blocker-spawn settings for the movement prototype.
blocker_spawn_timer = 1;
blocker_spawn_interval_min = 2.5;
blocker_spawn_interval_max = 4;
blocker_spawn_buffer = 64;
blocker_previous_lane_start = -1;

// Four measured lanes between the margins.
blocker_lane_left = 124;
blocker_lane_width = 208;
blocker_lane_count = 4;

// Temporary hazard testing switches.
debug_spawn_blockers = true;
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
