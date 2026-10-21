// Limit the time step so a lag spike cannot move the world an unsafe distance.
var delta_seconds = game_delta_seconds();

world_scroll_speed = min(
    world_scroll_speed + world_scroll_acceleration * delta_seconds,
    world_scroll_speed_max
);

world_scroll_delta = world_scroll_speed * delta_seconds;
distance_travelled += world_scroll_delta;

// M: spawn one Ticket Magnet in a random lane for testing.
if (keyboard_check_pressed(ord("M")) && !instance_exists(obj_powerup_magnet))
{
    var magnet_lane = irandom(blocker_lane_count - 1);
    var magnet_x = blocker_lane_left
        + (magnet_lane + 0.5) * blocker_lane_width;
    var magnet_sprite = object_get_sprite(obj_powerup_magnet);
    var magnet_y = -sprite_get_height(magnet_sprite) * 0.5;

    instance_create_layer(
        magnet_x,
        magnet_y,
        "powerup",
        obj_powerup_magnet
    );
}

// B: spawn one Double Ticket booster in a random lane for testing.
if (
    keyboard_check_pressed(ord("B"))
    && !instance_exists(obj_powerup_doubleticket)
)
{
    var booster_lane = irandom(blocker_lane_count - 1);
    var booster_x = blocker_lane_left
        + (booster_lane + 0.5) * blocker_lane_width;
    var booster_sprite = object_get_sprite(obj_powerup_doubleticket);
    var booster_y = -sprite_get_height(booster_sprite) * 0.5;

    instance_create_layer(
        booster_x,
        booster_y,
        "powerup",
        obj_powerup_doubleticket
    );
}

// G: spawn one one-hit Shield power-up in a random lane for testing.
if (keyboard_check_pressed(ord("G")) && !instance_exists(obj_powerup_shield))
{
    var shield_lane = irandom(blocker_lane_count - 1);
    var shield_x = blocker_lane_left
        + (shield_lane + 0.5) * blocker_lane_width;
    var shield_sprite = object_get_sprite(obj_powerup_shield);
    var shield_y = -sprite_get_height(shield_sprite) * 0.5;

    instance_create_layer(
        shield_x,
        shield_y,
        "powerup",
        obj_powerup_shield
    );
}

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

var lockon_is_clear = !instance_exists(obj_ufo_catcher)
    && !instance_exists(obj_key_pusher);
var lockon_support_hazards_clear = !instance_exists(obj_coin)
    && !instance_exists(obj_walking_duck);

// U and K remain manual test controls while preserving encounter exclusivity.
if (
    lockon_is_clear
    && lockon_support_hazards_clear
    && keyboard_check_pressed(ord("U"))
)
{
    instance_create_layer(0, 0, "Instances", obj_ufo_catcher);
    lockon_spawn_timer = random_range(
        lockon_cooldown_min,
        lockon_cooldown_max
    );
    coin_spawn_timer = max(coin_spawn_timer, coin_spawn_cooldown_min);
    duck_spawn_timer = max(duck_spawn_timer, duck_spawn_cooldown_min);
}
else if (
    lockon_is_clear
    && lockon_support_hazards_clear
    && keyboard_check_pressed(ord("K"))
)
{
    instance_create_layer(0, 0, "Instances", obj_key_pusher);
    lockon_spawn_timer = random_range(
        lockon_cooldown_min,
        lockon_cooldown_max
    );
    coin_spawn_timer = max(coin_spawn_timer, coin_spawn_cooldown_min);
    duck_spawn_timer = max(duck_spawn_timer, duck_spawn_cooldown_min);
}
else if (!debug_manual_lockon && lockon_is_clear)
{
    // Let the timer finish behind a coin/duck, then start as soon as they clear.
    lockon_spawn_timer = max(0, lockon_spawn_timer - delta_seconds);

    if (lockon_spawn_timer <= 0 && lockon_support_hazards_clear)
    {
        var lockon_object = (random(1) < 0.55)
            ? obj_ufo_catcher
            : obj_key_pusher;
        var lockon_player = instance_find(obj_player, 0);

        if (
            lockon_object == obj_ufo_catcher
            && !scr_ufo_has_escape_route(lockon_player)
        ) lockon_object = obj_key_pusher;

        instance_create_layer(0, 0, "Instances", lockon_object);
        lockon_spawn_timer = random_range(
            lockon_cooldown_min,
            lockon_cooldown_max
        );
        coin_spawn_timer = max(coin_spawn_timer, coin_spawn_cooldown_min);
        duck_spawn_timer = max(duck_spawn_timer, duck_spawn_cooldown_min);
    }
}

// Generate route-aware four-row formations. Pattern time pauses while a
// lock-on hazard owns the playfield.
var lockon_hazard_active_for_blockers = instance_exists(obj_ufo_catcher)
    || instance_exists(obj_key_pusher);

if (
    blocker_generation_enabled
    && blocker_spawn_timer <= 0
    && !(blocker_hazard_breathers && lockon_hazard_active_for_blockers)
)
{
    var blocker_difficulty = clamp(distance_travelled / 14000, 0, 1);

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

    var active_pattern = blocker_patterns[blocker_current_pattern_id];
    var active_row_index = blocker_reverse_current_pattern
        ? 3 - blocker_pattern_row
        : blocker_pattern_row;
    var blocker_row_mask = active_pattern.rows[active_row_index];

    var blocker_mutation_chance = lerp(0.32, 0.52, blocker_difficulty);
    if (random(1) < blocker_mutation_chance)
    {
        var triple_chance = lerp(0.10, 0.30, blocker_difficulty);
        blocker_row_mask = (random(1) < triple_chance)
            ? choose(7, 11, 13, 14)
            : choose(1, 2, 4, 8, 3, 6, 12, 9);
    }

    var blocker_breather_chance = lerp(0.075, 0.025, blocker_difficulty);
    if (blocker_row_mask != 0 && random(1) < blocker_breather_chance)
    {
        blocker_row_mask = 0;
    }

    if (blocker_mirror_current_pattern)
    {
        blocker_row_mask = scr_blocker_mirror_mask(blocker_row_mask);
    }

    var blocker_player = instance_find(obj_player, 0);
    var blocker_player_height = 260;
    var blocker_player_speed = 500;
    if (blocker_player != noone)
    {
        blocker_player_height = blocker_player.bbox_bottom
            - blocker_player.bbox_top + 1;
        blocker_player_speed = blocker_player.move_speed;
    }

    var blocker_sprite = object_get_sprite(obj_blocker1);
    var blocker_sprite_height = sprite_get_height(blocker_sprite);
    var lane_change_seconds = blocker_lane_width
        / max(1, blocker_player_speed);
    var minimum_lane_change_gap = blocker_sprite_height
        + blocker_player_height
        + world_scroll_speed * lane_change_seconds;
    var allow_blocker_lane_shift = blocker_distance_to_next_row
        >= minimum_lane_change_gap;

    if (
        !scr_blocker_mask_has_escape(blocker_row_mask, id)
        || !scr_blocker_masks_connected(
            blocker_previous_row_mask,
            blocker_row_mask,
            id,
            allow_blocker_lane_shift
        )
    )
    {
        blocker_row_mask = scr_blocker_pick_connected_mask(
            blocker_previous_row_mask,
            blocker_difficulty,
            id,
            allow_blocker_lane_shift
        );
    }

    scr_blocker_spawn_mask(blocker_row_mask, id);
    blocker_previous_row_mask = blocker_row_mask;

    blocker_pattern_row += 1;
    if (blocker_pattern_row >= 4)
    {
        array_push(blocker_recent_pattern_ids, blocker_current_pattern_id);
        if (array_length(blocker_recent_pattern_ids) > 5)
        {
            var trimmed_recent_ids = [];
            for (var recent_index = 1;
                recent_index < array_length(blocker_recent_pattern_ids);
                recent_index++)
            {
                array_push(
                    trimmed_recent_ids,
                    blocker_recent_pattern_ids[recent_index]
                );
            }
            blocker_recent_pattern_ids = trimmed_recent_ids;
        }

        blocker_pattern_row = 0;
        blocker_current_pattern_id = -1;
    }

    var next_row_is_close = blocker_pattern_row == 1
        || blocker_pattern_row == 3;
    var row_spacing = next_row_is_close
        ? random_range(
            blocker_cluster_spacing_min,
            blocker_cluster_spacing_max
        )
        : random_range(
            blocker_transition_spacing_min,
            blocker_transition_spacing_max
        );

    blocker_distance_to_next_row = row_spacing;
    blocker_spawn_timer = max(
        0.48,
        row_spacing / max(world_scroll_speed, 1)
    );
}
else if (
    blocker_generation_enabled
    && blocker_hazard_breathers
    && lockon_hazard_active_for_blockers
    && blocker_spawn_timer <= 0
)
{
    blocker_spawn_timer = 0.20;
}

// C forces the next coin tower for testing; otherwise it arrives occasionally.
coin_spawn_timer -= delta_seconds;
var coin_spawn_due = keyboard_check_pressed(ord("C"))
    || coin_spawn_timer <= 0;

if (
    coin_spawn_due
    && !instance_exists(obj_coin)
    && (
        keyboard_check_pressed(ord("C"))
        || (
            lockon_spawn_timer > 1.5
            && !instance_exists(obj_walking_duck)
            && !instance_exists(obj_ufo_catcher)
            && !instance_exists(obj_key_pusher)
        )
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
var duck_auto_clear = lockon_spawn_timer > 1.5
    && !instance_exists(obj_coin)
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
