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

    var spawn_x_min = blocker_spawn_left;
    var spawn_x_max = blocker_spawn_right - blocker_width;
    var spawn_y = -blocker_height - blocker_spawn_buffer;

    if (spawn_x_max >= spawn_x_min)
    {
        repeat (blocker_spawn_attempts)
        {
            var spawn_x = irandom_range(spawn_x_min, spawn_x_max);

            if (collision_rectangle(
                spawn_x,
                spawn_y,
                spawn_x + blocker_width - 1,
                spawn_y + blocker_height - 1,
                par_scrolling_blocker,
                false,
                true
            ) == noone)
            {
                instance_create_layer(spawn_x, spawn_y, "Instances", blocker_object);
                break;
            }
        }
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
