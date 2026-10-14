image_speed = 0;
image_index = 0;

// 1 attacks from the right; -1 attacks from the left.
ufo_side = choose(-1, 1);

// Draw the catcher as three horizontal pieces. The head and tail stay at
// their original size; only the straight middle shaft changes width.
var ufo_nine_slice = sprite_get_nineslice(sprite_index);
ufo_head_width = ufo_nine_slice.left;
ufo_tail_width = ufo_nine_slice.right;
ufo_middle_source_width = sprite_get_width(sprite_index)
    - ufo_head_width
    - ufo_tail_width;
ufo_minimum_width = sprite_get_width(sprite_index);
ufo_draw_width = ufo_minimum_width;
ufo_target_width = ufo_minimum_width;
ufo_claw_center_offset = ufo_head_width * 0.5;

// Rest with the claw tip at the inner edge of the margin. Begin one claw
// width farther out so the catcher slides into view instead of popping in.
var controller = instance_find(obj_controller, 0);
ufo_play_left = (controller != noone) ? controller.blocker_spawn_left : 128;
ufo_play_right = (controller != noone) ? controller.blocker_spawn_right : 960;

ufo_anchor_x = (ufo_side == 1)
    ? ufo_play_right + ufo_minimum_width
    : ufo_play_left - ufo_minimum_width;
ufo_offscreen_x = ufo_anchor_x + ufo_side * ufo_minimum_width;
x = ufo_offscreen_x;

var player = instance_find(obj_player, 0);
ufo_min_y = sprite_get_yoffset(sprite_index);
ufo_max_y = room_height
    - (sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index));
y = clamp(
    (player != noone) ? player.y : room_height * 0.5,
    ufo_min_y,
    ufo_max_y
);

ufo_state = UfoState.ENTER;
ufo_state_timer = 0;

ufo_track_speed = 700;
ufo_entry_duration = 0.6;
ufo_track_duration = 2.4;
ufo_lock_duration = 0.75;
ufo_close_duration = 0.35;
ufo_extend_speed = 900;
ufo_envelop_speed = 650;
ufo_retract_speed = 1100;
ufo_slide_progress = 0;
ufo_motion_start_width = ufo_draw_width;
ufo_motion_target_width = ufo_draw_width;
ufo_motion_progress = 0;
ufo_motion_duration = 0.1;

// Only this box around the claw head can capture the player. The stretched
// middle section is deliberately excluded.
ufo_hitbox_width = 120;
ufo_hitbox_height = 120;
ufo_caught_player = noone;
ufo_damage_applied = false;
ufo_envelop_target_width = ufo_minimum_width;
ufo_capture_y = y;
ufo_pull_progress = 0;
ufo_pull_center_duration = 0.25;

ufo_locked_x = x;
ufo_locked_y = y;

// Draw above gameplay objects. Collision will be added separately.
depth = -100000;