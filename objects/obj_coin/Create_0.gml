// One tower changes form; it never creates a second obstacle.
coin_state = 0; // 0 upright, 1 warning, 2 falling, 3 flat
coin_start_x = x;
coin_start_lane = 0;
coin_fall_direction = 1;
coin_target_x = x;
coin_lane_width = 208;
coin_lane_count = 4;
coin_warning_y = room_height * 0.30;
coin_warning_duration = 0.95;
coin_warning_timer = coin_warning_duration;
coin_fall_duration = 0.42;
coin_fall_progress = 0;
coin_scale = 1.10;
image_xscale = coin_scale;
image_yscale = coin_scale;
coin_shake_clock = 0;
coin_shake_x = 0;
coin_shake_y = 0;
coin_flat_shake_duration = 0.42;
coin_flat_shake_timer = 0;
image_speed = 0;

var run_controller = instance_find(obj_controller, 0);
if (run_controller != noone)
{
    var lane_left = run_controller.blocker_lane_left;
    var lane_width = run_controller.blocker_lane_width;
    coin_lane_width = lane_width;
    var lane_count = run_controller.blocker_lane_count;
    coin_lane_count = lane_count;
    coin_start_lane = clamp(
        floor((x - lane_left) / lane_width),
        0,
        lane_count - 1
    );

    if (coin_start_lane == 0)
    {
        coin_fall_direction = 1;
    }
    else if (coin_start_lane == lane_count - 1)
    {
        coin_fall_direction = -1;
    }
    else
    {
        coin_fall_direction = choose(-1, 1);
    }

    coin_start_x = lane_left + (coin_start_lane + 0.5) * lane_width;
    coin_target_x = coin_start_x + coin_fall_direction * lane_width;
    x = coin_start_x;
}
