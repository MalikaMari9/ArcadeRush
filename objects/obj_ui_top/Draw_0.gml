draw_self();

var ui_player = instance_find(obj_player, 0);
if (ui_player == noone)
{
    exit;
}

var ui_lives = clamp(ui_player.player_lives, 0, 3);
var portrait_sprite;

switch (ui_lives)
{
    case 3:
        portrait_sprite = spr_cat_front_bag;
        break;

    case 2:
        portrait_sprite = spr_cat_front_tag;
        break;

    case 1:
    default:
        portrait_sprite = spr_cat_front_body;
        break;
}

// Positions were measured from the temporary Debug asset layer.
draw_sprite(portrait_sprite, floor(ui_portrait_frame), 108, 126);

// The hurt body is layered over the current portrait so its bag or tag
// remains visible around the changed expression.
if (ui_hurt_active)
{
    draw_sprite(
        spr_cat_hurt_expression,
        floor(ui_portrait_frame),
        108,
        126
    );
}

// Mirror the active shield over the top-left character portrait.
if (ui_player.powerup_shield_timer > 0)
{
    var ui_shield_old_color = draw_get_color();
    var ui_shield_old_alpha = draw_get_alpha();
    var ui_shield_pulse = sin(ui_player.powerup_shield_visual_time * 5);
    var ui_shield_radius = max(
        sprite_get_width(portrait_sprite),
        sprite_get_height(portrait_sprite)
    ) * 0.58 + 12 + ui_shield_pulse * 3;
    var ui_shield_color = make_color_rgb(90, 220, 255);
    var ui_shield_expiry_alpha = 1;

    if (ui_player.powerup_shield_timer <= 2)
    {
        var ui_shield_blink_interval = (
            ui_player.powerup_shield_timer <= 0.75
        ) ? 0.10 : 0.22;

        if ((floor(
            ui_player.powerup_shield_timer / ui_shield_blink_interval
        ) mod 2) == 0)
        {
            ui_shield_expiry_alpha = 0.18;
        }
    }

    draw_set_color(ui_shield_color);
    draw_set_alpha(
        (0.08 + 0.025 * ui_shield_pulse) * ui_shield_expiry_alpha
    );
    draw_circle(108, 126, ui_shield_radius, false);

    draw_set_alpha(
        (0.55 + 0.12 * ui_shield_pulse) * ui_shield_expiry_alpha
    );
    draw_circle(108, 126, ui_shield_radius, true);
    draw_circle(108, 126, ui_shield_radius - 1, true);
    draw_circle(108, 126, ui_shield_radius - 2, true);

    draw_set_color(ui_shield_old_color);
    draw_set_alpha(ui_shield_old_alpha);
}

// Ticket Magnet timer: preserve the Debug-layer placement while wiping the
// animated icon away from top to bottom as the effect runs out.
if (ui_player.ticket_magnet_timer > 0)
{
    var magnet_progress = clamp(
        ui_player.ticket_magnet_timer / ui_player.ticket_magnet_duration,
        0,
        1
    );
    var magnet_width = sprite_get_width(spr_magnet_anim);
    var magnet_height = sprite_get_height(spr_magnet_anim);
    var magnet_visible_height = magnet_height * magnet_progress;
    var magnet_source_top = magnet_height - magnet_visible_height;
    var magnet_scale = 0.6875;
    var magnet_left = 129;
    var magnet_top = 69 + magnet_source_top * magnet_scale;

    draw_sprite_part_ext(
        spr_magnet_anim,
        floor(ui_magnet_frame),
        0,
        magnet_source_top,
        magnet_width,
        magnet_visible_height,
        magnet_left,
        magnet_top,
        magnet_scale,
        magnet_scale,
        c_white,
        1
    );
}

// Double Ticket timer: use the saved Debug-layer position and scale while
// wiping the animated icon away from top to bottom.
if (ui_player.ticket_double_timer > 0)
{
    var booster_progress = clamp(
        ui_player.ticket_double_timer / ui_player.ticket_double_duration,
        0,
        1
    );
    var booster_width = sprite_get_width(spr_double_ticket);
    var booster_height = sprite_get_height(spr_double_ticket);
    var booster_visible_height = booster_height * booster_progress;
    var booster_source_top = booster_height - booster_visible_height;
    var booster_scale_x = 0.61011165;
    var booster_scale_y = 0.6070611;
    var booster_left = 146.988835;
    var booster_top = 83.58779
        + booster_source_top * booster_scale_y;

    draw_sprite_part_ext(
        spr_double_ticket,
        floor(ui_double_ticket_frame),
        0,
        booster_source_top,
        booster_width,
        booster_visible_height,
        booster_left,
        booster_top,
        booster_scale_x,
        booster_scale_y,
        c_white,
        1
    );
}

// Heart index order follows remaining lives: lower-left, middle, upper-right.
var heart_x = [94, 226, 299];
var heart_y = [291, 210, 80];

for (var heart_index = 0; heart_index < 3; heart_index++)
{
    if (heart_index < ui_lives)
    {
        draw_sprite(
            spr_heart_burst_1,
            0,
            heart_x[heart_index],
            heart_y[heart_index]
        );
    }
    else if (ui_heart_bursting[heart_index])
    {
        draw_sprite(
            spr_heart_burst_1,
            floor(ui_heart_burst_frame[heart_index]),
            heart_x[heart_index],
            heart_y[heart_index]
        );
    }
}
