var delta_seconds = game_delta_seconds();
var player = instance_find(obj_player, 0);
key_elapsed += delta_seconds;

switch (key_state)
{
    // Follow both axes, with a small amount of smoothing instead of snapping.
    case KeyPusherState.TRACK:
        key_target_intro_progress = min(
            key_target_intro_progress
                + delta_seconds / key_target_intro_duration,
            1
        );

        if (player != noone)
        {
            var follow_dx = player.x - x;
            var follow_dy = player.y - y;
            var follow_distance = point_distance(x, y, player.x, player.y);

            if (follow_distance > 0)
            {
                var follow_amount = min(
                    1,
                    key_target_follow_speed * delta_seconds / follow_distance
                );
                x += follow_dx * follow_amount;
                y += follow_dy * follow_amount;
            }
        }

        key_state_timer -= delta_seconds;

        if (key_state_timer <= 0)
        {
            key_locked_x = x;
            key_locked_y = y;
            key_state = KeyPusherState.LOCKED_WARNING;
            key_state_timer = key_lock_duration;
        }
        break;

    // Hold the last tracked position so the player has a final escape window.
    case KeyPusherState.LOCKED_WARNING:
        x = key_locked_x;
        y = key_locked_y;
        key_state_timer -= delta_seconds;

        if (key_state_timer <= 0)
        {
            key_fall_start_y = -sprite_get_height(spr_key_master_key)
                * key_start_scale
                * 0.5;
            key_y = key_fall_start_y;
            key_scale = key_start_scale;
            key_fall_progress = 0;
            key_state = KeyPusherState.FALLING;
        }
        break;

    // Drop from above. Shrinking from oversized to normal suggests that the
    // key is descending out of the foreground toward the play surface.
    case KeyPusherState.FALLING:
        key_fall_progress = min(
            key_fall_progress + delta_seconds / key_fall_duration,
            1
        );

        var fall_eased = power(key_fall_progress, 2);
        key_y = lerp(key_fall_start_y, key_locked_y, fall_eased);
        key_scale = lerp(key_start_scale, 1, key_fall_progress);

        if (key_fall_progress >= 1)
        {
            key_y = key_locked_y;
            key_scale = 1;

            if (!key_damage_applied)
            {
                var hit_player = collision_circle(
                    key_locked_x,
                    key_locked_y,
                    key_impact_radius,
                    obj_player,
                    false,
                    true
                );

                if (
                    hit_player != noone
                    && !hit_player.ufo_captured
                    && !hit_player.invulnerable
                )
                {
                    with (hit_player)
                    {
                        if (player_apply_hazard_damage())
                        {
                            player_start_hazard_invulnerability();
                        }
                    }
                }

                key_damage_applied = true;
            }

            key_state = KeyPusherState.IMPACT;
            key_state_timer = key_impact_linger_duration;
        }
        break;

    // Leave the result readable for a moment, then free the shared cooldown.
    case KeyPusherState.IMPACT:
        key_state_timer -= delta_seconds;

        if (key_state_timer <= 0)
        {
            instance_destroy();
        }
        break;
}