var scalper_controller = instance_find(obj_controller, 0);
var scalper_world_speed = (scalper_controller != noone)
    ? scalper_controller.world_scroll_speed
    : scalper_reference_scroll_speed;
var scalper_target_fps = scalper_base_animation_fps
    * scalper_world_speed
    / scalper_reference_scroll_speed;
var scalper_player = instance_find(obj_player, 0);
var scalper_game_over = scalper_player != noone
    && scalper_player.player_dead;

// Preserve the current crowd frame at game over. The bite state machine must
// continue so a lethal Scalper capture can still finish releasing the player.
image_speed = scalper_game_over
    ? 0
    : scalper_target_fps / scalper_native_animation_fps;

if (scalper_entering)
{
    scalper_entry_progress = min(
        scalper_entry_progress
            + game_delta_seconds() / scalper_entry_duration,
        1
    );

    var entry_eased = 1 - power(1 - scalper_entry_progress, 3);
    y = lerp(scalper_start_y, scalper_rest_y, entry_eased);

    if (scalper_entry_progress >= 1)
    {
        y = scalper_rest_y;
        scalper_entering = false;
    }
}
else
{
    var scalper_delta = game_delta_seconds();

    switch (scalper_bite_state)
    {
        case 0:
            x = scalper_rest_x;
            y = scalper_rest_y;
            image_angle = scalper_rest_angle;

            var bite_target = instance_find(obj_player, 0);
            if (
                bite_target != noone
                && !bite_target.ufo_captured
                && !bite_target.scalper_captured
                && !bite_target.invulnerable
                && bite_target.bbox_bottom
                    >= bbox_top + scalper_danger_offset
            )
            {
                scalper_bite_player = bite_target;
                bite_target.scalper_captured = true;
                var cover_distance = max(
                    scalper_lunge_minimum,
                    bbox_top
                        - bite_target.bbox_top
                        + scalper_cover_padding
                );
                scalper_lunge_y = scalper_rest_y - cover_distance;
                scalper_bite_progress = 0;
                scalper_bite_state = 1;
            }
            break;

        case 1:
            scalper_bite_progress = min(
                scalper_bite_progress
                    + scalper_delta / scalper_lunge_duration,
                1
            );
            var lunge_eased = 1 - power(1 - scalper_bite_progress, 3);
            y = lerp(
                scalper_rest_y,
                scalper_lunge_y,
                lunge_eased
            );

            if (scalper_bite_progress >= 1)
            {
                if (instance_exists(scalper_bite_player))
                {
                    with (scalper_bite_player)
                    {
                        player_apply_hazard_damage(
                            PlayerDamageCause.SCALPER
                        );
                    }

                    // Damage swaps to the next life sprite, whose mask can
                    // extend higher than the one used to plan the lunge.
                    // Deepen the completed bite immediately so every life
                    // sprite is fully covered before the struggle begins.
                    var post_damage_cover = bbox_top
                        - scalper_bite_player.bbox_top
                        + scalper_cover_padding;
                    if (post_damage_cover > 0)
                    {
                        y -= post_damage_cover;
                        scalper_lunge_y = y;
                    }

                    scalper_bite_player_offset_y
                        = scalper_bite_player.y - y;
                }

                scalper_bite_timer = scalper_hold_duration;
                scalper_bite_state = 2;
            }
            break;

        case 2:
            y = scalper_lunge_y;
            scalper_bite_timer -= scalper_delta;

            if (scalper_bite_timer <= 0)
            {
                scalper_bite_progress = 0;
                scalper_bite_state = 3;
            }
            break;

        case 3:
            scalper_bite_progress = min(
                scalper_bite_progress
                    + scalper_delta / scalper_return_duration,
                1
            );
            var return_eased = power(scalper_bite_progress, 2);
            y = lerp(
                scalper_lunge_y,
                scalper_rest_y,
                return_eased
            );

            // Carry the swallowed player with the crowd so they remain fully
            // covered until the Scalpers finish returning to rest.
            if (instance_exists(scalper_bite_player))
            {
                scalper_bite_player.y = y + scalper_bite_player_offset_y;
            }

            if (scalper_bite_progress >= 1)
            {
                y = scalper_rest_y;

                if (instance_exists(scalper_bite_player))
                {
                    var release_player = scalper_bite_player;
                    var release_danger_y = bbox_top + scalper_danger_offset;
                    var release_gap = scalper_safe_gap;

                    with (release_player)
                    {
                        var release_left_offset = bbox_left - x;
                        var release_right_offset = bbox_right - x;
                        var release_top_offset = bbox_top - y;
                        var release_bottom_offset = bbox_bottom - y;
                        var release_min_x = -release_left_offset;
                        var release_max_x
                            = (room_width - 1) - release_right_offset;
                        var release_min_y = -release_top_offset;
                        var release_x = clamp(x, release_min_x, release_max_x);
                        var release_y = max(
                            release_min_y,
                            release_danger_y
                                - release_gap
                                - release_bottom_offset
                        );
                        var release_found = false;
                        var release_step = 8;

                        // Prefer the space directly above the bite, then fan
                        // upward and sideways if a blocker occupies it.
                        for (
                            var release_ring = 0;
                            release_ring <= 20 && !release_found;
                            release_ring++
                        )
                        {
                            for (
                                var release_horizontal = -release_ring;
                                release_horizontal <= release_ring
                                    && !release_found;
                                release_horizontal++
                            )
                            {
                                var release_up = release_ring
                                    - abs(release_horizontal);
                                var candidate_x = clamp(
                                    release_x
                                        + release_horizontal * release_step,
                                    release_min_x,
                                    release_max_x
                                );
                                var candidate_y = max(
                                    release_min_y,
                                    release_y - release_up * release_step
                                );

                                if (!place_meeting(candidate_x, candidate_y, par_blocker))
                                {
                                    other.scalper_spit_target_x = candidate_x;
                                    other.scalper_spit_target_y = candidate_y;
                                    release_found = true;
                                }
                            }
                        }

                        // The intended point is still preferable to leaving
                        // the player inside the crowd in an unusually packed
                        // obstacle layout.
                        if (!release_found)
                        {
                            other.scalper_spit_target_x = release_x;
                            other.scalper_spit_target_y = release_y;
                        }
                    }

                    scalper_spit_start_x = release_player.x;
                    scalper_spit_start_y = release_player.y;
                    scalper_struggle_elapsed = 0;
                    scalper_bite_timer = scalper_struggle_duration;
                    scalper_bite_state = 4;
                }
                else
                {
                    scalper_bite_player = noone;
                    scalper_bite_state = 0;
                }
            }
            break;

        case 4:
            scalper_struggle_elapsed += scalper_delta;
            scalper_bite_timer = max(0, scalper_bite_timer - scalper_delta);

            // An uneven positional and rotational shake makes the swallowed
            // player's struggle readable without exposing their sprite.
            x = scalper_rest_x
                + sin(scalper_struggle_elapsed * 360 * 7)
                    * scalper_shake_x;
            y = scalper_rest_y
                + sin(scalper_struggle_elapsed * 360 * 11)
                    * scalper_shake_y;
            image_angle = scalper_rest_angle
                + sin(scalper_struggle_elapsed * 360 * 9)
                    * scalper_shake_angle;

            if (
                scalper_bite_timer <= 0
                || !instance_exists(scalper_bite_player)
            )
            {
                x = scalper_rest_x;
                y = scalper_rest_y;
                image_angle = scalper_rest_angle;

                if (instance_exists(scalper_bite_player))
                {
                    scalper_spit_start_x = scalper_bite_player.x;
                    scalper_spit_start_y = scalper_bite_player.y;
                    scalper_bite_progress = 0;
                    scalper_bite_state = 5;
                }
                else
                {
                    scalper_bite_player = noone;
                    scalper_bite_state = 0;
                }
            }
            break;

        case 5:
            x = scalper_rest_x;
            y = scalper_rest_y;
            image_angle = scalper_rest_angle;
            scalper_bite_progress = min(
                scalper_bite_progress
                    + scalper_delta / scalper_spit_duration,
                1
            );

            if (instance_exists(scalper_bite_player))
            {
                var spit_eased = 1 - power(1 - scalper_bite_progress, 3);
                scalper_bite_player.x = lerp(
                    scalper_spit_start_x,
                    scalper_spit_target_x,
                    spit_eased
                );
                scalper_bite_player.y = lerp(
                    scalper_spit_start_y,
                    scalper_spit_target_y,
                    spit_eased
                );
            }

            if (scalper_bite_progress >= 1)
            {
                if (instance_exists(scalper_bite_player))
                {
                    with (scalper_bite_player)
                    {
                        scalper_captured = false;
                        player_start_hazard_invulnerability();
                    }
                }

                scalper_bite_player = noone;
                scalper_bite_state = 0;
            }
            break;
    }
}
