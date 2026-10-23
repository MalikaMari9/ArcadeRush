var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
var box_x = gui_width * 0.5;
var box_y = gui_height * 0.5;

// Hold the stopped run visibly behind the presentation.
draw_set_alpha(0.32);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_width, gui_height, false);
draw_set_alpha(1);
draw_set_color(c_white);

// The main panel pops slightly past full size before settling.
var box_progress = clamp(
    game_over_time / game_over_box_duration,
    0,
    1
);
var box_eased = 1 - power(1 - box_progress, 3);
var box_scale = box_eased + sin(box_progress * pi) * 0.08;
draw_sprite_ext(
    spr_box_base,
    0,
    box_x,
    box_y,
    box_scale,
    box_scale,
    0,
    c_white,
    1
);

// Preserve the full-size composition laid out on the room's Debug layer.
// Each illustration deliberately extends beyond the panel by a different
// amount, so it must not be scaled down to fit inside the box.
var illustration = player_game_over_sprite(game_over_cause);
var illustration_offset_x = 0;
var illustration_offset_y = -192;
var illustration_angle = 0;

switch (illustration)
{
    case spr_gameover_coin:
        illustration_offset_x = 32;
        illustration_offset_y = -96;
        break;

    case spr_gameover_duck_explosion:
        illustration_offset_y = -128;
        illustration_angle = -1.3046132;
        break;

    case spr_gameover_duck_shoot:
        illustration_offset_y = -160;
        break;

    case spr_gameover_ufo:
        illustration_offset_x = -32;
        illustration_offset_y = -256;
        break;
}

var illustration_scale = 1;
var illustration_height = sprite_get_height(illustration);
var drop_progress = clamp(
    (game_over_time - game_over_illustration_delay)
        / game_over_illustration_duration,
    0,
    1
);
var drop_eased = 1 - power(1 - drop_progress, 3);
var drop_start_y = -illustration_height * illustration_scale * 0.5;
var drop_target_x = box_x + illustration_offset_x;
var drop_target_y = box_y + illustration_offset_y;
var illustration_y = lerp(drop_start_y, drop_target_y, drop_eased);

if (drop_progress > 0)
{
    draw_sprite_ext(
        illustration,
        0,
        drop_target_x,
        illustration_y,
        illustration_scale,
        illustration_scale,
        illustration_angle,
        c_white,
        1
    );
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Temporary Retry control. This can become the scoreboard button later.
var retry_progress = clamp(
    (game_over_time - game_over_retry_delay)
        / game_over_retry_duration,
    0,
    1
);
if (retry_progress > 0)
{
    var retry_eased = 1 - power(1 - retry_progress, 3);
    var retry_y = box_y + 180;
    var retry_color = make_color_rgb(114, 103, 157);
    var retry_width = 360 * retry_eased;
    var retry_height = 105 * retry_eased;
    var retry_left = box_x - retry_width * 0.5;
    var retry_top = retry_y - retry_height * 0.5;
    var retry_right = box_x + retry_width * 0.5;
    var retry_bottom = retry_y + retry_height * 0.5;
    var retry_border = make_color_rgb(181, 157, 211);
    var retry_fill = make_color_rgb(252, 247, 255);

    draw_set_alpha(0.12 * retry_progress);
    draw_set_color(make_color_rgb(91, 69, 133));
    draw_roundrect(
        retry_left + 4,
        retry_top + 5,
        retry_right + 4,
        retry_bottom + 5,
        false
    );

    draw_set_alpha(retry_progress);
    draw_set_color(retry_border);
    draw_roundrect(
        retry_left,
        retry_top,
        retry_right,
        retry_bottom,
        false
    );
    draw_set_color(retry_fill);
    draw_roundrect(
        retry_left + 3,
        retry_top + 3,
        retry_right - 3,
        retry_bottom - 3,
        false
    );

    draw_set_alpha(retry_progress);
    draw_set_color(retry_color);
    draw_text_transformed(
        box_x,
        retry_y,
        "Retry",
        2,
        2,
        0
    );
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
