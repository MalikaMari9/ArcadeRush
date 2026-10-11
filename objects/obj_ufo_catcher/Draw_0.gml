var horizontal_scale = ufo_draw_width / sprite_get_width(sprite_index);

if (ufo_side == -1)
{
    horizontal_scale = -horizontal_scale;
}

draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    horizontal_scale,
    1,
    0,
    c_white,
    1
);
// Temporary visual aid for tuning the claw-head capture area.
if (ufo_state == 4)
{
    var debug_claw_x = (ufo_side == 1)
        ? x - ufo_draw_width + ufo_claw_center_offset
        : x + ufo_draw_width - ufo_claw_center_offset;
    var debug_half_width = ufo_hitbox_width * 0.5;
    var debug_half_height = ufo_hitbox_height * 0.5;

    draw_set_alpha(0.9);
    draw_set_color(instance_exists(ufo_caught_player) ? c_lime : c_red);
    draw_rectangle(
        debug_claw_x - debug_half_width,
        y - debug_half_height,
        debug_claw_x + debug_half_width,
        y + debug_half_height,
        true
    );
    draw_set_color(c_white);
    draw_set_alpha(1);
}