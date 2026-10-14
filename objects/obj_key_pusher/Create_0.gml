image_speed = 0;
depth = -100000;

var player = instance_find(obj_player, 0);
x = (player != noone) ? player.x : room_width * 0.5;
y = (player != noone) ? player.y : room_height * 0.5;

key_state = KeyPusherState.TRACK;
key_state_timer = 2.4;
key_elapsed = 0;

key_target_follow_speed = 900;
key_target_intro_duration = 0.2;
key_target_intro_progress = 0;
key_lock_duration = 0.75;
key_fall_duration = 0.7;
key_impact_hold_duration = 0.45;
key_impact_fade_duration = 0.35;
key_impact_linger_duration = key_impact_hold_duration
    + key_impact_fade_duration;
key_impact_radius = 72;
key_start_scale = 2.2;

key_locked_x = x;
key_locked_y = y;
key_fall_start_y = -sprite_get_height(spr_key_master_key)
    * key_start_scale
    * 0.5;
key_y = key_fall_start_y;
key_scale = key_start_scale;
key_fall_progress = 0;
key_damage_applied = false;