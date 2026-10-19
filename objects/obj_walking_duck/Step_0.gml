var delta_seconds = game_delta_seconds();
var player = instance_find(obj_player, 0);

// Touching the duck detonates it immediately, even before it can shoot.
if (duck_state < 5 && player != noone && place_meeting(x, y, obj_player))
{
    duck_state = 5;
    duck_explosion_timer = duck_explosion_duration;
}

switch (duck_state)
{
    case 0: // Walk toward the player's current X, then lock the position.
        duck_walk_frame = (duck_walk_frame
            + duck_walk_fps * delta_seconds) mod 4;
        image_index = duck_walk_frame_base + floor(duck_walk_frame);

        if (player != noone)
        {
            var half_width = sprite_get_width(spr_duck_walk) * 0.5;
            var target_x = clamp(
                player.x,
                128 + half_width,
                960 - half_width
            );
            var move_step = duck_walk_speed * delta_seconds;

            if (abs(target_x - x) <= move_step)
            {
                x = target_x;
                duck_state = 1;
                duck_state_timer = 0.30;
                sprite_index = spr_duck_shoot;
                image_index = 0;
                image_speed = 0;
            }
            else
            {
                var walk_direction = sign(target_x - x);
                image_xscale = -walk_direction;
                x += walk_direction * move_step;
            }
        }
        break;

    case 1: // Shoot pose, frame 0.
        duck_state_timer -= delta_seconds;
        if (duck_state_timer <= 0)
        {
            duck_state = 2;
            duck_state_timer = 0.22;
            image_index = 1;
        }
        break;

    case 2: // Shoot pose, frame 1; then release one projectile.
        duck_state_timer -= delta_seconds;
        if (duck_state_timer <= 0)
        {
            var aim_x = (player != noone) ? player.x : x;
            var aim_y = (player != noone) ? player.y : room_height;
            var aim_distance = max(
                1,
                point_distance(x, y, aim_x, aim_y)
            );
            array_push(duck_bullets, {
                x: x,
                y: y,
                vx: (aim_x - x) / aim_distance * duck_bullet_speed,
                vy: (aim_y - y) / aim_distance * duck_bullet_speed,
                timer: 1.4
            });
            duck_shots_remaining -= 1;

            if (duck_shots_remaining > 0)
            {
                duck_state = 1;
                duck_state_timer = 0.20;
                image_index = 0;
            }
            else
            {
                duck_state = 3;
                duck_state_timer = duck_post_shot_pause;
                image_index = 1;
            }
        }
        break;

    case 3: // Hold completely still after the final shot.
        duck_state_timer = max(0, duck_state_timer - delta_seconds);
        if (duck_state_timer <= 0)
        {
            duck_state = 4;
            duck_shake_timer = duck_shake_duration;
        }
        break;

    case 4: // Shake violently after the pause, then explode.
        duck_shake_timer = max(0, duck_shake_timer - delta_seconds);
        var shake_progress = 1
            - duck_shake_timer / duck_shake_duration;
        var shake_strength = lerp(4, 13, shake_progress);
        duck_shake_x = sin(shake_progress * pi * 28) * shake_strength;
        duck_shake_y = sin(shake_progress * pi * 39)
            * shake_strength * 0.55;

        if (duck_shake_timer <= 0)
        {
            duck_shake_x = 0;
            duck_shake_y = 0;
            duck_state = 5;
            duck_explosion_timer = duck_explosion_duration;
        }
        break;

    case 5:
        if (!duck_explosion_applied)
        {
            var explosion_hit = collision_circle(
                x, y, duck_explosion_radius,
                obj_player, false, true
            );
            if (
                explosion_hit != noone
                && !explosion_hit.ufo_captured
                && !explosion_hit.scalper_captured
            )
            {
                with (explosion_hit)
                {
                    if (player_apply_hazard_damage())
                    {
                        player_start_hazard_invulnerability();
                    }
                }
            }
            duck_explosion_applied = true;
        }

        duck_explosion_timer = max(
            0,
            duck_explosion_timer - delta_seconds
        );
        break;
}

// Projectiles continue independently so a full volley can exist at once.
for (var bullet_index = array_length(duck_bullets) - 1;
    bullet_index >= 0; bullet_index--)
{
    var bullet = duck_bullets[bullet_index];
    var previous_bullet_x = bullet.x;
    var previous_bullet_y = bullet.y;
    bullet.x += bullet.vx * delta_seconds;
    bullet.y += bullet.vy * delta_seconds;
    bullet.timer -= delta_seconds;

    var bullet_hit = collision_line(
        previous_bullet_x, previous_bullet_y,
        bullet.x, bullet.y,
        obj_player, false, true
    );
    if (bullet_hit == noone)
    {
        bullet_hit = collision_circle(
            bullet.x, bullet.y,
            duck_bullet_radius,
            obj_player, false, true
        );
    }
    if (
        bullet_hit != noone
        && !bullet_hit.ufo_captured
        && !bullet_hit.scalper_captured
    )
    {
        with (bullet_hit)
        {
            if (player_apply_hazard_damage())
            {
                player_start_hazard_invulnerability();
            }
        }
        array_delete(duck_bullets, bullet_index, 1);
        continue;
    }

    if (
        bullet.timer <= 0
        || bullet.x < -32
        || bullet.x > room_width + 32
        || bullet.y < -32
        || bullet.y > room_height + 32
    )
    {
        array_delete(duck_bullets, bullet_index, 1);
    }
}

if (duck_state == 5 && duck_explosion_timer <= 0
    && array_length(duck_bullets) == 0)
{
    instance_destroy();
}
