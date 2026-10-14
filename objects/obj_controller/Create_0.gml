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
blocker_spawn_attempts = 8;
blocker_spawn_buffer = 64;

// Temporary hazard testing switches.
debug_spawn_blockers = false;
debug_manual_lockon = true;

// Current control-area edges created by the side margins in rm_gameRoom.
blocker_spawn_left = 128;
blocker_spawn_right = 960;

// UFO and Key Pusher share one scheduler and never overlap.
lockon_spawn_timer = 3;
lockon_cooldown_min = 10;
lockon_cooldown_max = 20;

randomise();
