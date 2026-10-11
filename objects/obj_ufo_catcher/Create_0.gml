image_speed = 0;
image_index = 0;

// 1 attacks from the right; -1 attacks from the left.
ufo_side = choose(-1, 1);

// The fixed left and right nine-slice regions total 250 pixels.
ufo_minimum_width = 250;
ufo_draw_width = ufo_minimum_width;
ufo_target_width = ufo_minimum_width;
ufo_claw_center_offset = 75;

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
y = (player != noone) ? player.y : room_height * 0.5;

// State 0: enter, 1: track, 2: lock warning, 3: extend,
//       4: close, 5: retract, 6: exit.
ufo_state = 0;
ufo_state_timer = 0;

ufo_track_speed = 700;
ufo_entry_duration = 0.6;
ufo_track_duration = 2.4;
ufo_lock_duration = 0.75;
ufo_close_duration = 0.35;
ufo_extend_speed = 900;
ufo_retract_speed = 1100;
ufo_slide_progress = 0;

// Only this box around the claw head can capture the player. The stretched
// middle section is deliberately excluded.
ufo_hitbox_width = 120;
ufo_hitbox_height = 120;
ufo_caught_player = noone;

ufo_locked_x = x;
ufo_locked_y = y;

// Draw above gameplay objects. Collision will be added separately.
depth = -100000;