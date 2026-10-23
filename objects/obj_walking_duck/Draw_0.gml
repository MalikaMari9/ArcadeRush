var old_color = draw_get_color();
var old_alpha = draw_get_alpha();

if (duck_state == 5)
{
    if (duck_explosion_timer > 0)
    {
        var explosion_progress = clamp(
            1 - duck_explosion_timer / duck_explosion_duration,
            0,
            1
        );
        var explosion_frames = sprite_get_number(spr_explosion_anim);
        var explosion_frame = min(
            explosion_frames - 1,
            floor(explosion_progress * explosion_frames)
        );
        var explosion_scale = duck_explosion_radius * 2
            / max(
                sprite_get_width(spr_explosion_anim),
                sprite_get_height(spr_explosion_anim)
            );

        draw_sprite_ext(
            spr_explosion_anim,
            explosion_frame,
            x,
            y,
            explosion_scale,
            explosion_scale,
            0,
            c_white,
            1
        );
    }
}
else
{
    draw_sprite_ext(
        sprite_index,
        image_index,
        x + duck_shake_x,
        y + duck_shake_y,
        image_xscale,
        image_yscale,
        image_angle,
        image_blend,
        image_alpha
    );
}

for (var bullet_index = 0;
    bullet_index < array_length(duck_bullets); bullet_index++)
{
    var bullet = duck_bullets[bullet_index];
    var bullet_angle = point_direction(
        0, 0, bullet.vx, bullet.vy
    ) - 90;
    draw_sprite_ext(
        spr_duck_bullet,
        0,
        bullet.x,
        bullet.y,
        1,
        1,
        bullet_angle,
        c_white,
        1
    );
}

draw_set_color(old_color);
draw_set_alpha(old_alpha);
