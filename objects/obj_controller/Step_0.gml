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

// Ticket opportunities follow generated distance sections, independently of
// whether a particular section contains a blocker or a lock-on hazard.
ticket_distance_to_next_opportunity -= world_scroll_delta;
if (ticket_distance_to_next_opportunity <= 0)
{
    var ticket_difficulty = clamp(distance_travelled / 14000, 0, 1);
    var ticket_chance = lerp(
        ticket_opportunity_chance_early,
        ticket_opportunity_chance_mid,
        min(1, ticket_difficulty / 0.5)
    );
    if (ticket_difficulty >= 0.5)
    {
        ticket_chance = lerp(
            ticket_opportunity_chance_mid,
            ticket_opportunity_chance_late,
            (ticket_difficulty - 0.5) / 0.5
        );
    }

    var ticket_roll_succeeded = random(1) < ticket_chance;
    var ticket_candidates_tested = 0;
    var ticket_rejections = 0;
    var ticket_placement_found = false;
    var ticket_active_cap_blocked = false;
    var ticket_segment_roll = irandom(99);
    var ticket_segment_count = 1;
    if (ticket_segment_roll >= 85) ticket_segment_count = 3;
    else if (ticket_segment_roll >= 55) ticket_segment_count = 2;

    if (
        ticket_roll_succeeded
        && instance_number(par_ticket) + ticket_segment_count
            <= ticket_active_max
    )
    {
        // Reuse the current ticket objects, 1/2/3 formation, and value rolls.
        var ticket_sprite = object_get_sprite(obj_ticket_1);
        var ticket_width = sprite_get_width(ticket_sprite);
        var ticket_height = sprite_get_height(ticket_sprite);
        var ticket_origin_x = sprite_get_xoffset(ticket_sprite);
        var ticket_origin_y = sprite_get_yoffset(ticket_sprite);
        var ticket_spacing = 123;
        var ticket_left_limit = blocker_spawn_left + ticket_width * 0.5;
        var ticket_right_limit = blocker_spawn_right - ticket_width * 0.5;
        var ticket_y = -ticket_spawn_buffer
            - (ticket_height - ticket_origin_y)
            - (ticket_segment_count - 1) * ticket_spacing;
        var ticket_clearance = lerp(
            ticket_safe_clearance_early,
            ticket_safe_clearance_late,
            ticket_difficulty
        );
        var ticket_x = 0;
        // The blocker mask already retains its escape route. Tickets do not
        // collide with the player, so nearby formations offer optional risk.
        // Reject only direct/crowded intersections with scrolling blockers;
        // active UFOs, pushers, coins, ducks, and the Scalpers are not vetoes.
        for (var ticket_attempt = 0;
            ticket_attempt < ticket_placement_attempts;
            ticket_attempt++)
        {
            ticket_candidates_tested++;
            var candidate_x = random_range(
                ticket_left_limit + ticket_origin_x,
                ticket_right_limit - (ticket_width - ticket_origin_x)
            );
            var candidate_clear = true;

            for (var ticket_segment = 0;
                ticket_segment < ticket_segment_count;
                ticket_segment++)
            {
                var candidate_y = ticket_y
                    + ticket_segment * ticket_spacing;
                var candidate_left = candidate_x - ticket_origin_x
                    - ticket_clearance;
                var candidate_top = candidate_y - ticket_origin_y
                    - ticket_clearance;
                var candidate_right = candidate_x
                    + (ticket_width - ticket_origin_x)
                    + ticket_clearance;
                var candidate_bottom = candidate_y
                    + (ticket_height - ticket_origin_y)
                    + ticket_clearance;

                if (collision_rectangle(
                    candidate_left,
                    candidate_top,
                    candidate_right,
                    candidate_bottom,
                    par_scrolling_blocker,
                    false,
                    true
                ) != noone)
                {
                    candidate_clear = false;
                    ticket_rejections++;
                    break;
                }
            }

            if (candidate_clear)
            {
                ticket_x = candidate_x;
                ticket_placement_found = true;
                break;
            }
        }

        if (ticket_placement_found)
        {
            for (var ticket_index = 0;
                ticket_index < ticket_segment_count;
                ticket_index++)
            {
                var ticket_value_roll = irandom(99);
                var ticket_object = obj_ticket_1;
                if (ticket_value_roll >= 90) ticket_object = obj_ticket_5;
                else if (ticket_value_roll >= 60) ticket_object = obj_ticket_2;

                instance_create_layer(
                    ticket_x,
                    ticket_y + ticket_index * ticket_spacing,
                    "Tickets",
                    ticket_object
                );
            }
        }
    }
    else if (ticket_roll_succeeded)
    {
        ticket_active_cap_blocked = true;
    }

    if (ticket_debug_logging)
    {
        var ticket_result = "spawned";
        if (!ticket_roll_succeeded) ticket_result = "chance failed";
        else if (ticket_active_cap_blocked) ticket_result = "active cap";
        else if (!ticket_placement_found) ticket_result = "no clear position";

        show_debug_message(
            "Ticket opportunity: " + ticket_result
            + ", chance=" + string(ticket_chance)
            + ", candidates=" + string(ticket_candidates_tested)
            + ", rejected=" + string(ticket_rejections)
        );
    }

    // A distance-based section interval keeps occurrence tied to progression
    // rather than to elapsed seconds or successful prior spawns.
    ticket_distance_to_next_opportunity = random_range(
        ticket_opportunity_spacing_min,
        ticket_opportunity_spacing_max
    );
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
