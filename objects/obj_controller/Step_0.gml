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

blocker_spawn_timer -= delta_seconds;

if (debug_spawn_blockers && blocker_spawn_timer <= 0)
{
    var blocker_object = choose(obj_blocker1, obj_blocker2, obj_blocker3);
    var blocker_sprite = object_get_sprite(blocker_object);
    var blocker_width = sprite_get_width(blocker_sprite);
    var blocker_height = sprite_get_height(blocker_sprite);

    // Create above the room first so the inherited lane_occupy property can
    // determine placement. Sprite width is a safe fallback while an object
    // property edit is still unsaved in the IDE.
    var spawned_blocker = instance_create_layer(
        0,
        -blocker_height - blocker_spawn_buffer,
        "Obstacles",
        blocker_object
    );

    if (spawned_blocker != noone)
    {
        var property_lane_span = round(spawned_blocker.lane_occupy);
        var width_lane_span = round(blocker_width / blocker_lane_width);
        var lane_span = clamp(
            max(property_lane_span, width_lane_span),
            1,
            blocker_lane_count
        );
        spawned_blocker.lane_occupy = lane_span;

        var maximum_lane_start = blocker_lane_count - lane_span;
        var lane_start = irandom(maximum_lane_start);

        // Avoid repeating the exact same starting lane when another valid
        // position exists, while keeping the result random.
        if (maximum_lane_start > 0 && lane_start == blocker_previous_lane_start)
        {
            lane_start = (lane_start + irandom_range(1, maximum_lane_start))
                mod (maximum_lane_start + 1);
        }

        var lane_center = blocker_lane_left
            + (lane_start + lane_span * 0.5) * blocker_lane_width;
        var blocker_bottom_from_origin = blocker_height
            - sprite_get_yoffset(blocker_sprite);

        spawned_blocker.x = lane_center;
        spawned_blocker.y = -blocker_bottom_from_origin
            - blocker_spawn_buffer;
        blocker_previous_lane_start = lane_start;
    }

    blocker_spawn_timer = random_range(
        blocker_spawn_interval_min,
        blocker_spawn_interval_max
    );
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
