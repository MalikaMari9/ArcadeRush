var delta_seconds = min(delta_time / 1000000, 1 / 15);
var player = instance_find(obj_player, 0);

switch (ufo_state)
{
    // Slide in from offscreen while following the player's height.
    case 0:
        if (player != noone)
        {
            var enter_target_y = clamp(player.y, 100, room_height - 100);
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
            ufo_state = 1;
            ufo_state_timer = ufo_track_duration;
        }
        break;

    // Track the player's vertical position from inside the margin.
    case 1:
        if (player != noone)
        {
            var target_y = clamp(player.y, 100, room_height - 100);
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

            y = clamp(ufo_locked_y, 100, room_height - 100);
            ufo_target_width = max(
                ufo_minimum_width,
                abs(x - ufo_locked_x) + ufo_claw_center_offset
            );

            image_index = 1;
            ufo_state = 2;
            ufo_state_timer = ufo_lock_duration;
        }
        break;

    // Hold the locked location briefly before committing to the strike.
    case 2:
        ufo_state_timer -= delta_seconds;

        if (ufo_state_timer <= 0)
        {
            ufo_state = 3;
        }
        break;

    // Extend horizontally to the player's position captured at lock time.
    case 3:
        ufo_draw_width = min(
            ufo_draw_width + ufo_extend_speed * delta_seconds,
            ufo_target_width
        );

        if (ufo_draw_width >= ufo_target_width)
        {
            ufo_draw_width = ufo_target_width;
            image_index = 0;

            // Test only the claw head at the instant it closes.
            var impact_claw_x = (ufo_side == 1)
                ? x - ufo_draw_width + ufo_claw_center_offset
                : x + ufo_draw_width - ufo_claw_center_offset;
            var hitbox_half_width = ufo_hitbox_width * 0.5;
            var hitbox_half_height = ufo_hitbox_height * 0.5;
            var caught = collision_rectangle(
                impact_claw_x - hitbox_half_width,
                y - hitbox_half_height,
                impact_claw_x + hitbox_half_width,
                y + hitbox_half_height,
                obj_player,
                false,
                true
            );

            if (caught != noone && !caught.ufo_captured)
            {
                ufo_caught_player = caught;
                caught.ufo_captured = true;
                caught.ufo_captor = id;
                caught.x = impact_claw_x;
                caught.y = y;
            }

            ufo_state = 4;
            ufo_state_timer = ufo_close_duration;
        }
        break;

    // Keep the claw closed briefly before retracting.
    case 4:
        if (instance_exists(ufo_caught_player))
        {
            var held_claw_x = (ufo_side == 1)
                ? x - ufo_draw_width + ufo_claw_center_offset
                : x + ufo_draw_width - ufo_claw_center_offset;
            ufo_caught_player.x = held_claw_x;
            ufo_caught_player.y = y;
        }
        else
        {
            ufo_caught_player = noone;
        }

        ufo_state_timer -= delta_seconds;

        if (ufo_state_timer <= 0)
        {
            ufo_state = 5;
        }
        break;

    // Retract the claw and carry a caught player toward the margin.
    case 5:
        ufo_draw_width = max(
            ufo_draw_width - ufo_retract_speed * delta_seconds,
            ufo_minimum_width
        );

        if (instance_exists(ufo_caught_player))
        {
            var retract_claw_x = (ufo_side == 1)
                ? x - ufo_draw_width + ufo_claw_center_offset
                : x + ufo_draw_width - ufo_claw_center_offset;
            ufo_caught_player.x = retract_claw_x;
            ufo_caught_player.y = y;
        }
        else
        {
            ufo_caught_player = noone;
        }

        if (ufo_draw_width <= ufo_minimum_width)
        {
            ufo_draw_width = ufo_minimum_width;

            // Temporary prototype release: place the player just inside the
            // play area. Protection and game-over outcomes will replace this.
            if (instance_exists(ufo_caught_player))
            {
                var release_player = ufo_caught_player;
                var release_left_offset = release_player.bbox_left - release_player.x;
                var release_right_offset = release_player.bbox_right - release_player.x;
                var release_top_offset = release_player.bbox_top - release_player.y;
                var release_bottom_offset = release_player.bbox_bottom - release_player.y;

                release_player.x = (ufo_side == 1)
                    ? ufo_play_right - 8 - release_right_offset
                    : ufo_play_left + 8 - release_left_offset;
                release_player.y = clamp(
                    y,
                    -release_top_offset,
                    (room_height - 1) - release_bottom_offset
                );

                // If a blocker occupies the release point, search inward for
                // the nearest clear horizontal position.
                var release_direction = -ufo_side;
                var release_search = ceil(ufo_play_right - ufo_play_left);
                repeat (release_search)
                {
                    var release_overlap = collision_rectangle(
                        release_player.bbox_left,
                        release_player.bbox_top,
                        release_player.bbox_right,
                        release_player.bbox_bottom,
                        par_blocker,
                        false,
                        true
                    );

                    if (release_overlap == noone)
                    {
                        break;
                    }

                    release_player.x += release_direction;
                }

                release_player.ufo_captured = false;
                release_player.ufo_captor = noone;
                ufo_caught_player = noone;
            }

            ufo_state = 6;
            ufo_slide_progress = 0;
        }
        break;

    // Slide completely offscreen, then allow the next attack to be scheduled.
    case 6:
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