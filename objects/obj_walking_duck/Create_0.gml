// A screen-fixed encounter: the scrolling room does not move the duck.
duck_state = 0; // walk, prepare, shoot, pause, violent shake, explosion
duck_walk_speed = 380;
duck_explosion_radius = 150;
duck_explosion_duration = 0.45;
duck_explosion_timer = 0;
duck_explosion_applied = false;
duck_state_timer = 0;
duck_shots_total = choose(1, 3, 5);
duck_shots_remaining = duck_shots_total;
duck_walk_frame_base = (duck_shots_total == 1)
    ? 0
    : ((duck_shots_total == 3) ? 4 : 8);
duck_walk_frame = 0;
duck_walk_fps = 9;
duck_post_shot_pause = 1.0;
duck_shake_duration = 0.80;
duck_shake_timer = 0;
duck_shake_x = 0;
duck_shake_y = 0;

duck_bullet_speed = 900;
duck_bullet_radius = sprite_get_width(spr_duck_bullet) * 0.5;
duck_bullets = [];

sprite_index = spr_duck_walk;
image_index = duck_walk_frame_base;
image_speed = 0;
y = room_height * 0.32;

duck_entry_side = choose(-1, 1);
var duck_half_width = sprite_get_width(spr_duck_walk) * 0.5;
x = (duck_entry_side == -1)
    ? -duck_half_width
    : room_width + duck_half_width;
// The authored sprite faces left at positive scale.
image_xscale = (duck_entry_side == -1) ? -1 : 1;
// Keep this screen-fixed encounter above ordinary scrolling obstacles while
// leaving capture hazards, Scalpers, and the UI in front of it.
depth = -90000;
