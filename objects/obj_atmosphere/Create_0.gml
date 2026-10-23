// Reusable full-frame Colour Burn controls.
atmosphere_enabled = true;
atmosphere_colour = make_colour_rgb(136, 97, 205);
atmosphere_strength = .5;

atmosphere_surface = -1;
atmosphere_capture_active = false;
atmosphere_burn_colour_uniform = shader_get_uniform(
    shd_color_burn,
    "u_burn_colour"
);
atmosphere_burn_strength_uniform = shader_get_uniform(
    shd_color_burn,
    "u_burn_strength"
);
