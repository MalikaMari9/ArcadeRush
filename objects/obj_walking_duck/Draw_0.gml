// Debug circle: this same radius is used for explosion damage.
var old_color = draw_get_color();
var old_alpha = draw_get_alpha();
draw_set_color(c_red);
draw_set_alpha(0.75);
draw_circle(x, y, duck_explosion_radius, true);
draw_set_color(old_color);
draw_set_alpha(old_alpha);

if (duck_state == 5)
{
    var explosion_progress = 1
        - duck_explosion_timer / duck_explosion_duration;
    draw_set_color(c_red);
    draw_set_alpha(0.26 * (1 - explosion_progress));
    draw_circle(x, y, duck_explosion_radius, false);
    draw_set_color(old_color);
    draw_set_alpha(old_alpha);
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
