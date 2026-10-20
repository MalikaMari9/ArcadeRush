// Limit the time step so a lag spike cannot move the world an unsafe distance.
var delta_seconds = game_delta_seconds();

world_scroll_speed = min(
    world_scroll_speed + world_scroll_acceleration * delta_seconds,
    world_scroll_speed_max
);

world_scroll_delta = world_scroll_speed * delta_seconds;
distance_travelled += world_scroll_delta;

// Spawn collectible ticket strips in random lanes. Higher denominations and
// longer strips are intentionally less common.
ticket_spawn_timer -= delta_seconds;

if (ticket_spawn_timer <= 0 && instance_number(par_ticket) < ticket_active_max)
{
    var segment_roll = irandom(99);
    var segment_count = 1;

    if (segment_roll >= 85)
    {
        segment_count = 3;
    }
    else if (segment_roll >= 55)
    {
        segment_count = 2;
    }

    var ticket_lane = irandom(blocker_lane_count - 1);
    var ticket_x = blocker_lane_left
        + (ticket_lane + 0.5) * blocker_lane_width;
    // All ticket sprites currently share these dimensions and origins.
    var ticket_sprite = object_get_sprite(obj_ticket_1);
    var ticket_height = sprite_get_height(ticket_sprite);
    var ticket_origin_y = sprite_get_yoffset(ticket_sprite);
    var ticket_spacing = 123;
    var strip_height = ticket_height
        + (segment_count - 1) * ticket_spacing;
    var ticket_y = -ticket_spawn_buffer
        - (ticket_height - ticket_origin_y)
        - (segment_count - 1) * ticket_spacing;
    var lane_left = blocker_lane_left
        + ticket_lane * blocker_lane_width;
    var lane_right = lane_left + blocker_lane_width;

    // Delay briefly if an obstacle is already entering through this lane.
    if (collision_rectangle(
        lane_left,
        ticket_y - ticket_origin_y,
        lane_right,
        strip_height,
        par_scrolling_blocker,
        false,
        true
    ) == noone)
    {
        for (var segment = 0; segment < segment_count; segment++)
        {
            var ticket_roll = irandom(99);
            var ticket_object = obj_ticket_1;

            if (ticket_roll >= 90)
            {
                ticket_object = obj_ticket_5;
            }
            else if (ticket_roll >= 60)
            {
                ticket_object = obj_ticket_2;
            }

            instance_create_layer(
                ticket_x,
                ticket_y + segment * ticket_spacing,
                "Tickets",
                ticket_object
            );
        }

        ticket_spawn_timer = random_range(
            ticket_spawn_cooldown_min,
            ticket_spawn_cooldown_max
        );
    }
    else
    {
        ticket_spawn_timer = ticket_spawn_retry;
    }
}

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

// Temporary manual test callers: K = Key Pusher, U = UFO Catcher.
if (debug_manual_lockon)
{
    if (lockon_is_clear)
    {
        if (keyboard_check_pressed(ord("K")))
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

// C forces the next coin tower for testing; otherwise it arrives occasionally.
coin_spawn_timer -= delta_seconds;
var coin_spawn_due = keyboard_check_pressed(ord("C"))
    || coin_spawn_timer <= 0;

if (
    coin_spawn_due
    && !instance_exists(obj_coin)
    && (
        !instance_exists(obj_walking_duck)
        || keyboard_check_pressed(ord("C"))
    )
)
{
    var coin_lane = irandom(blocker_lane_count - 1);
    var coin_x = blocker_lane_left
        + (coin_lane + 0.5) * blocker_lane_width;
    var coin_y = -coin_spawn_buffer;

    // Keep the arrival clear of obstacles already entering from above.
    if (collision_rectangle(
        coin_x - blocker_lane_width * 0.5,
        coin_y - sprite_get_height(spr_coins),
        coin_x + blocker_lane_width * 0.5,
        coin_y + blocker_lane_width,
        par_scrolling_blocker,
        false,
        true
    ) == noone)
    {
        instance_create_layer(coin_x, coin_y, "Obstacles", obj_coin);
        coin_spawn_timer = random_range(
            coin_spawn_cooldown_min,
            coin_spawn_cooldown_max
        );
    }
}

// H forces a duck for testing; automatic encounters wait for other hazards.
duck_spawn_timer -= delta_seconds;
var duck_manual_spawn = keyboard_check_pressed(ord("H"));
var duck_auto_clear = !instance_exists(obj_coin)
    && !instance_exists(obj_ufo_catcher)
    && !instance_exists(obj_key_pusher);

if (
    !instance_exists(obj_walking_duck)
    && (duck_manual_spawn || (duck_spawn_timer <= 0 && duck_auto_clear))
)
{
    instance_create_layer(0, 0, "Instances", obj_walking_duck);
    duck_spawn_timer = random_range(
        duck_spawn_cooldown_min,
        duck_spawn_cooldown_max
    );
}
