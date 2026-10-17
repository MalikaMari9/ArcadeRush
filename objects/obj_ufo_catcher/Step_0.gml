var delta_seconds = game_delta_seconds();
var player = instance_find(obj_player, 0);

switch (ufo_state)
{
    // Slide in from offscreen while following the player's height.
    case UfoState.ENTER:
        if (player != noone)
        {
            var enter_target_y = clamp(player.y, ufo_min_y, ufo_max_y);
            var enter_track_amount = ufo_track_speed * delta_seconds;
            y += clamp(enter_target_y - y, -enter_track_amount, enter_track_amount);
        }

        ufo_slide_progress = min(
            ufo_slide_progress + delta_seconds / ufo_entry_duration,
            1
        );
        var enter_eased = 1 - power(1 - ufo_slide_progress, 3);
        x = lerp(ufo_offscreen_x, ufo_anchor_x, enter_eased);

        if (ufo_slide_progress >= 1)
        {
            x = ufo_anchor_x;
            ufo_state = UfoState.TRACK;
            ufo_state_timer = ufo_track_duration;
        }
        break;

    // Track the player's vertical position from inside the margin.
    case UfoState.TRACK:
        if (player != noone)
        {
            var target_y = clamp(player.y, ufo_min_y, ufo_max_y);
            var track_amount = ufo_track_speed * delta_seconds;
            y += clamp(target_y - y, -track_amount, track_amount);
        }

        ufo_state_timer -= delta_seconds;

        if (ufo_state_timer <= 0)
        {
            if (player != noone)
            {
                ufo_locked_x = player.x;
                ufo_locked_y = player.y;
            }

            y = clamp(ufo_locked_y, ufo_min_y, ufo_max_y);
            ufo_target_width = max(
                ufo_minimum_width,
                abs(x - ufo_locked_x) + ufo_claw_center_offset
            );

            image_index = 1;
            ufo_state = UfoState.LOCKED_WARNING;
            ufo_state_timer = ufo_lock_duration;
        }
        break;

    // Hold the locked location briefly before committing to the strike.
    case UfoState.LOCKED_WARNING:
        ufo_state_timer -= delta_seconds;

        if (ufo_state_timer <= 0)
        {
            ufo_motion_start_width = ufo_draw_width;
            ufo_motion_target_width = ufo_target_width;
            ufo_motion_progress = 0;
            ufo_motion_duration = max(
                0.08,
                (ufo_motion_target_width - ufo_motion_start_width)
                    / ufo_extend_speed
            );
            ufo_state = UfoState.EXTEND;
        }
        break;

    // Extend horizontally to the player's position captured at lock time.
    case UfoState.EXTEND:
        var previous_claw_x = (ufo_side == 1)
            ? x - ufo_draw_width + ufo_claw_center_offset
            : x + ufo_draw_width - ufo_claw_center_offset;

        ufo_motion_progress = min(
            ufo_motion_progress + delta_seconds / ufo_motion_duration,
            1
        );
        var strike_eased = power(ufo_motion_progress, 2);
        ufo_draw_width = lerp(
            ufo_motion_start_width,
            ufo_motion_target_width,
            strike_eased
        );

        var current_claw_x = (ufo_side == 1)
            ? x - ufo_draw_width + ufo_claw_center_offset
            : x + ufo_draw_width - ufo_claw_center_offset;
        var hitbox_half_width = ufo_hitbox_width * 0.5;
        var hitbox_half_height = ufo_hitbox_height * 0.5;

        // Check the complete distance crossed by the claw head this frame so
        // a fast strike cannot skip through the player between steps.
        var caught = collision_rectangle(
            min(previous_claw_x, current_claw_x) - hitbox_half_width,
            y - hitbox_half_height,
            max(previous_claw_x, current_claw_x) + hitbox_half_width,
            y + hitbox_half_height,
            obj_player,
            false,
            true
        );

        if (
            caught != noone
            && !caught.ufo_captured
            && !caught.scalper_captured
            && !caught.invulnerable
        )
        {
            ufo_caught_player = caught;
            caught.ufo_captured = true;
            caught.ufo_captor = id;
            ufo_capture_y = caught.y;
            ufo_envelop_target_width = max(
                ufo_draw_width,
                abs(x - caught.x) + ufo_claw_center_offset
            );
            ufo_motion_start_width = ufo_draw_width;
            ufo_motion_target_width = ufo_envelop_target_width;
            ufo_motion_progress = 0;
            ufo_motion_duration = max(
                0.12,
                (ufo_motion_target_width - ufo_motion_start_width)
                    / ufo_envelop_speed
            );
            ufo_state = UfoState.ENVELOP;
        }
        else if (ufo_draw_width >= ufo_target_width)
        {
            ufo_draw_width = ufo_target_width;
            image_index = 0;
            ufo_state = UfoState.CLOSE;
            ufo_state_timer = ufo_close_duration;
        }
        break;

    // Keep the player still while the open claw moves around them.
    case UfoState.ENVELOP:
        if (instance_exists(ufo_caught_player))
        {
            ufo_motion_progress = min(
                ufo_motion_progress + delta_seconds / ufo_motion_duration,
                1
            );
            var envelop_eased = 1 - power(1 - ufo_motion_progress, 3);
            ufo_draw_width = lerp(
                ufo_motion_start_width,
                ufo_motion_target_width,
                envelop_eased
            );

            if (ufo_motion_progress >= 1)
            {
                ufo_draw_width = ufo_envelop_target_width;
                image_index = 0;
                ufo_state = UfoState.CLOSE;
                ufo_state_timer = ufo_close_duration;
            }
        }
        else
        {
            ufo_caught_player = noone;
            image_index = 0;
            ufo_state = UfoState.CLOSE;
            ufo_state_timer = ufo_close_duration;
        }
        break;

    // Keep the claw closed briefly before retracting.
    case UfoState.CLOSE:
        ufo_state_timer -= delta_seconds;

        if (ufo_state_timer <= 0)
        {
            ufo_pull_progress = 0;
            ufo_motion_start_width = ufo_draw_width;
            ufo_motion_target_width = ufo_minimum_width;
            ufo_motion_progress = 0;
            ufo_motion_duration = max(
                0.18,
                (ufo_motion_start_width - ufo_motion_target_width)
                    / ufo_retract_speed
            );
            ufo_state = UfoState.RETRACT;
        }
        break;

    // Retract the claw and carry a caught player toward the margin.
    case UfoState.RETRACT:
        ufo_motion_progress = min(
            ufo_motion_progress + delta_seconds / ufo_motion_duration,
            1
        );
        var retract_eased = 1 - power(1 - ufo_motion_progress, 2);
        ufo_draw_width = lerp(
            ufo_motion_start_width,
            ufo_motion_target_width,
            retract_eased
        );

        if (instance_exists(ufo_caught_player))
        {
            var retract_claw_x = (ufo_side == 1)
                ? x - ufo_draw_width + ufo_claw_center_offset
                : x + ufo_draw_width - ufo_claw_center_offset;
            ufo_pull_progress = min(
                ufo_pull_progress + delta_seconds / ufo_pull_center_duration,
                1
            );
            var pull_eased = 1 - power(1 - ufo_pull_progress, 3);
            ufo_caught_player.x = retract_claw_x;
            ufo_caught_player.y = lerp(ufo_capture_y, y, pull_eased);
        }
        else
        {
            ufo_caught_player = noone;
        }

        if (ufo_motion_progress >= 1)
        {
            ufo_draw_width = ufo_minimum_width;

            var release_completed = true;

            // Apply damage, switch to the resulting collision mask, then find
            // a genuinely clear position before returning player control.
            if (instance_exists(ufo_caught_player))
            {
                release_completed = false;
                var release_player = ufo_caught_player;

                if (!ufo_damage_applied)
                {
                    with (release_player)
                    {
                        player_apply_hazard_damage();
                    }

                    ufo_damage_applied = true;
                }

                var release_left_offset = release_player.bbox_left - release_player.x;
                var release_right_offset = release_player.bbox_right - release_player.x;
                var release_top_offset = release_player.bbox_top - release_player.y;
                var release_bottom_offset = release_player.bbox_bottom - release_player.y;
                var release_direction = -ufo_side;
                var release_min_x = ufo_play_left + 8 - release_left_offset;
                var release_max_x = ufo_play_right - 8 - release_right_offset;
                var release_min_y = -release_top_offset;
                var release_max_y = (room_height - 1) - release_bottom_offset;
                var release_base_x = (ufo_side == 1)
                    ? release_max_x
                    : release_min_x;
                var release_base_y = clamp(y, release_min_y, release_max_y);
                var release_found = false;
                var release_step = 8;
                var release_local_rings = ceil(160 / release_step);

                // Search outward from the intended margin point in a diamond,
                // favouring the nearest combination of inward/vertical shift.
                for (
                    var release_ring = 0;
                    release_ring <= release_local_rings && !release_found;
                    release_ring++
                )
                {
                    for (
                        var release_vertical_step = -release_ring;
                        release_vertical_step <= release_ring && !release_found;
                        release_vertical_step++
                    )
                    {
                        var release_inward_step
                            = release_ring - abs(release_vertical_step);
                        var release_candidate_x = release_base_x
                            + release_direction
                            * release_inward_step
                            * release_step;
                        var release_candidate_y = clamp(
                            release_base_y
                                + release_vertical_step * release_step,
                            release_min_y,
                            release_max_y
                        );

                        if (
                            release_candidate_x >= release_min_x
                            && release_candidate_x <= release_max_x
                        )
                        {
                            release_player.x = release_candidate_x;
                            release_player.y = release_candidate_y;

                            with (release_player)
                            {
                                release_found = !place_meeting(
                                    x,
                                    y,
                                    par_blocker
                                );
                            }
                        }
                    }
                }

                // If the nearby area is crowded, scan the complete playable
                // area before delaying the release until a later step.
                for (
                    var release_scan_y = release_min_y;
                    release_scan_y <= release_max_y && !release_found;
                    release_scan_y += release_step
                )
                {
                    for (
                        var release_scan_x = release_min_x;
                        release_scan_x <= release_max_x && !release_found;
                        release_scan_x += release_step
                    )
                    {
                        release_player.x = release_scan_x;
                        release_player.y = release_scan_y;

                        with (release_player)
                        {
                            release_found = !place_meeting(x, y, par_blocker);
                        }
                    }
                }

                if (release_found)
                {
                    release_player.ufo_captured = false;
                    release_player.ufo_captor = noone;
                    with (release_player)
                    {
                        player_start_hazard_invulnerability();
                    }
                    ufo_caught_player = noone;
                    release_completed = true;
                }
            }

            if (release_completed)
            {
                ufo_state = UfoState.EXIT;
                ufo_slide_progress = 0;
            }
        }
        break;

    // Slide completely offscreen, then allow the next attack to be scheduled.
    case UfoState.EXIT:
        ufo_slide_progress = min(
            ufo_slide_progress + delta_seconds / ufo_entry_duration,
            1
        );
        var exit_eased = 1 - power(1 - ufo_slide_progress, 3);
        x = lerp(ufo_anchor_x, ufo_offscreen_x, exit_eased);

        if (ufo_slide_progress >= 1)
        {
            instance_destroy();
        }
        break;
}
