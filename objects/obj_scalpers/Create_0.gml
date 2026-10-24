scalper_base_animation_fps = 6;
scalper_native_animation_fps = 9;
scalper_reference_scroll_speed = 120;
image_speed = scalper_base_animation_fps / scalper_native_animation_fps;

// The room position is the permanent resting position chosen in the editor.
// Only Y changes during the one-time entrance; X and rotation are preserved.
scalper_rest_x = x;
scalper_rest_y = y - 100;
scalper_rest_angle = image_angle;

// The crowd is a foreground boundary. Keep it in front of scrolling
// obstacles regardless of their feet-based dynamic depth.
depth = -100000;
var scalper_horizontal_extent = max(
    sprite_get_xoffset(sprite_index),
    sprite_get_width(sprite_index) - sprite_get_xoffset(sprite_index)
);
var scalper_upward_extent
    = sprite_get_yoffset(sprite_index) * abs(cos(image_angle))
    + scalper_horizontal_extent * abs(sin(image_angle));
scalper_start_y = max(room_height, scalper_rest_y)
    + ceil(scalper_upward_extent)
    + 2;
scalper_entry_duration = 1.25;
scalper_entry_progress = 0;
scalper_entering = true;
scalper_entry_started = false;

// Let the player enter the artwork slightly before the crowd bites.
scalper_danger_offset = 60;
scalper_safe_gap = 80;

// Bite states: 0 idle, 1 lunge, 2 hold, 3 return, 4 struggle, 5 spit.
scalper_bite_state = 0;
scalper_bite_player = noone;
scalper_bite_progress = 0;
scalper_bite_timer = 0;
scalper_lunge_minimum = 55;
scalper_cover_padding = 28;
scalper_lunge_y = scalper_rest_y;
scalper_bite_player_offset_y = 0;
scalper_lunge_duration = 0.12;
scalper_hold_duration = 0.10;
scalper_return_duration = 0.22;
scalper_struggle_duration = 1.5;
scalper_struggle_elapsed = 0;
scalper_shake_x = 6;
scalper_shake_y = 3;
scalper_shake_angle = 1.25;
scalper_spit_duration = 0.32;
scalper_spit_start_x = 0;
scalper_spit_start_y = 0;
scalper_spit_target_x = 0;
scalper_spit_target_y = 0;

y = scalper_start_y;
