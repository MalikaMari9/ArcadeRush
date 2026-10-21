draw_self();

// Temporary code-drawn shield bubble, rendered over the player.
if (powerup_shield_timer > 0)
{
    var shield_old_color = draw_get_color();
    var shield_old_alpha = draw_get_alpha();
    var shield_pulse = sin(powerup_shield_visual_time * 5);
    var shield_center_x = (bbox_left + bbox_right) * 0.5;
    var shield_center_y = (bbox_top + bbox_bottom) * 0.5;
    var shield_radius = max(
        bbox_right - bbox_left,
        bbox_bottom - bbox_top
    ) * 0.58 + 12 + shield_pulse * 3;
    var shield_color = make_color_rgb(90, 220, 255);
    var shield_expiry_alpha = 1;

    if (powerup_shield_timer <= 2)
    {
        var shield_blink_interval = (powerup_shield_timer <= 0.75)
            ? 0.10
            : 0.22;

        if ((floor(powerup_shield_timer / shield_blink_interval) mod 2) == 0)
        {
            shield_expiry_alpha = 0.18;
        }
    }

    draw_set_color(shield_color);
    draw_set_alpha(
        (0.08 + 0.025 * shield_pulse) * shield_expiry_alpha
    );
    draw_circle(shield_center_x, shield_center_y, shield_radius, false);

    draw_set_alpha(
        (0.55 + 0.12 * shield_pulse) * shield_expiry_alpha
    );
    draw_circle(shield_center_x, shield_center_y, shield_radius, true);
    draw_circle(shield_center_x, shield_center_y, shield_radius - 1, true);
    draw_circle(shield_center_x, shield_center_y, shield_radius - 2, true);

    draw_set_color(shield_old_color);
    draw_set_alpha(shield_old_alpha);
}

if (ticket_magnet_timer > 0)
{
    var magnet_bob = sin(ticket_magnet_visual_time * 5) * 6;
    var magnet_alpha = (ufo_captured || scalper_captured) ? 0.45 : 0.9;
    var magnet_draw_x = x;

    if (ticket_double_timer > 0)
    {
        magnet_draw_x -= 40;
    }

    // Warn before natural expiration. The last 0.75 seconds blink faster;
    // damage cancellation remains immediate and skips this warning.
    if (ticket_magnet_timer <= 2)
    {
        var magnet_blink_interval = (ticket_magnet_timer <= 0.75)
            ? 0.10
            : 0.22;

        if ((floor(ticket_magnet_timer / magnet_blink_interval) mod 2) == 0)
        {
            magnet_alpha *= 0.18;
        }
    }

    draw_sprite_ext(
        spr_magnet_anim,
        floor(ticket_magnet_visual_frame),
        magnet_draw_x,
        bbox_top - 45 + magnet_bob,
        0.35,
        0.35,
        0,
        c_white,
        magnet_alpha
    );
}

if (ticket_double_timer > 0)
{
    var booster_bob = sin(ticket_double_visual_time * 5) * 6;
    var booster_alpha = (ufo_captured || scalper_captured) ? 0.45 : 0.9;
    var booster_draw_x = x;

    if (ticket_magnet_timer > 0)
    {
        booster_draw_x += 40;
    }

    if (ticket_double_timer <= 2)
    {
        var booster_blink_interval = (ticket_double_timer <= 0.75)
            ? 0.10
            : 0.22;

        if ((floor(ticket_double_timer / booster_blink_interval) mod 2) == 0)
        {
            booster_alpha *= 0.18;
        }
    }

    draw_sprite_ext(
        spr_double_ticket,
        floor(ticket_double_visual_frame),
        booster_draw_x,
        bbox_top - 45 + booster_bob,
        0.35,
        0.35,
        0,
        c_white,
        booster_alpha
    );
}
