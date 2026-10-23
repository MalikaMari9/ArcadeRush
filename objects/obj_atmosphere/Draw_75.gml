if (!atmosphere_capture_active)
{
    exit;
}

surface_reset_target();
atmosphere_capture_active = false;

var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
var burn_red = colour_get_red(atmosphere_colour) / 255;
var burn_green = colour_get_green(atmosphere_colour) / 255;
var burn_blue = colour_get_blue(atmosphere_colour) / 255;

shader_set(shd_color_burn);
shader_set_uniform_f(
    atmosphere_burn_colour_uniform,
    burn_red,
    burn_green,
    burn_blue
);
shader_set_uniform_f(
    atmosphere_burn_strength_uniform,
    clamp(atmosphere_strength, 0, 1)
);
draw_surface_stretched(
    atmosphere_surface,
    0,
    0,
    gui_width,
    gui_height
);
shader_reset();

draw_set_colour(c_white);
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
