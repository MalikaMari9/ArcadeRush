if (!atmosphere_enabled || atmosphere_strength <= 0)
{
    exit;
}

var strength = clamp(atmosphere_strength, 0, 1);
var multiply_colour = merge_colour(c_white, atmosphere_colour, strength);

gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
draw_set_colour(multiply_colour);
draw_set_alpha(1);
draw_rectangle(0, 0, room_width, room_height, false);

// Always restore shared draw state for objects drawn afterward.
gpu_set_blendmode(bm_normal);
draw_set_colour(c_white);
draw_set_alpha(1);