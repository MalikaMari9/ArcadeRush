// Limit the time step so a lag spike cannot move the world an unsafe distance.
var delta_seconds = game_delta_seconds();

world_scroll_speed = min(
    world_scroll_speed + world_scroll_acceleration * delta_seconds,
    world_scroll_speed_max
);

// Temporary speed testing: K increases and J decreases the
// shared world speed in visible 30-pixel-per-second steps.
if (keyboard_check_pressed(ord("K")))
{
    world_scroll_speed = min(
        world_scroll_speed + debug_world_speed_step,
        world_scroll_speed_max
    );
}
else if (keyboard_check_pressed(ord("J")))
{
    world_scroll_speed = max(
        world_scroll_speed - debug_world_speed_step,
        debug_world_speed_min
    );
}

world_scroll_delta = world_scroll_speed * delta_seconds;
distance_travelled += world_scroll_delta;

if (blocker_generation_enabled)
{
    blocker_spawn_timer -= delta_seconds;

    if (blocker_spawn_timer <= 0)
    {
        var blocker_difficulty = clamp(distance_travelled / 14000, 0, 1);

        // Select a new four-row formation after the previous one completes.
        if (blocker_pattern_row == 0)
        {
            blocker_current_pattern_id = scr_blocker_pick_pattern(
                blocker_patterns,
                blocker_difficulty,
                blocker_recent_pattern_ids
            );
            blocker_mirror_current_pattern = (irandom(1) == 1);
            blocker_reverse_current_pattern = (irandom(1) == 1);
        }

        var blocker_pattern = blocker_patterns[blocker_current_pattern_id];
        var blocker_row_index = blocker_pattern_row;
        if (blocker_reverse_current_pattern)
        {
            blocker_row_index = 3 - blocker_row_index;
        }

        var blocker_row_mask = blocker_pattern.rows[blocker_row_index];

        // Mutate occasional single rows without changing their safe footprint.
        if (
            blocker_row_mask == 1
            || blocker_row_mask == 2
            || blocker_row_mask == 4
            || blocker_row_mask == 8
        )
        {
            var blocker_mutation_chance = lerp(
                0.14,
                0.28,
                blocker_difficulty
            );
            if (random(1) < blocker_mutation_chance)
            {
                blocker_row_mask = choose(1, 2, 4, 8);
            }
        }

        // Hard lock-on attacks receive an empty row so their telegraphs remain
        // readable and the player is not forced through two threats at once.
        var blocker_lockon_active = instance_exists(obj_ufo_catcher)
            || instance_exists(obj_key_pusher);
        if (blocker_hazard_breathers && blocker_lockon_active)
        {
            blocker_row_mask = 0;
        }
        else
        {
            var blocker_breather_chance = lerp(
                0.12,
                0.045,
                blocker_difficulty
            );
            if (random(1) < blocker_breather_chance)
            {
                blocker_row_mask = 0;
            }
        }

        if (blocker_mirror_current_pattern)
        {
            blocker_row_mask = scr_blocker_mirror_mask(blocker_row_mask);
        }

        scr_blocker_spawn_mask(blocker_row_mask, id);

        blocker_pattern_row += 1;
        if (blocker_pattern_row >= 4)
        {
            array_push(
                blocker_recent_pattern_ids,
                blocker_current_pattern_id
            );
            if (array_length(blocker_recent_pattern_ids) > 5)
            {
                array_delete(blocker_recent_pattern_ids, 0, 1);
            }

            blocker_pattern_row = 0;
            blocker_current_pattern_id = -1;
        }

        var blocker_spacing = lerp(
            blocker_row_spacing_max,
            blocker_row_spacing_min,
            blocker_difficulty
        );
        var blocker_spacing_variation = random_range(0.92, 1.08);
        blocker_spawn_timer = max(
            0.65,
            blocker_spacing
                / max(world_scroll_speed, 1)
                * blocker_spacing_variation
        );
    }
}

var lockon_is_clear = !instance_exists(obj_ufo_catcher)
    && !instance_exists(obj_key_pusher);

// Temporary manual test callers: P = Key Pusher, U = UFO Catcher.
if (debug_manual_lockon)
{
    if (lockon_is_clear)
    {
        if (keyboard_check_pressed(ord("P")))
        {
            instance_create_layer(0, 0, "Instances", obj_key_pusher);
        }
        else if (keyboard_check_pressed(ord("U")))
        {
            instance_create_layer(0, 0, "Instances", obj_ufo_catcher);
        }
    }
}
// Normal shared random scheduler, retained for when testing is finished.
else if (lockon_is_clear)
{
    lockon_spawn_timer -= delta_seconds;

    if (lockon_spawn_timer <= 0)
    {
        var lockon_object = choose(obj_ufo_catcher, obj_key_pusher);
        instance_create_layer(0, 0, "Instances", lockon_object);
        lockon_spawn_timer = random_range(
            lockon_cooldown_min,
            lockon_cooldown_max
        );
    }
}
