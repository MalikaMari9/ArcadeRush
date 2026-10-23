// Limit the time step so a lag spike cannot move the world an unsafe distance.
var delta_seconds = game_delta_seconds();

// A lethal hit is deliberately not an immediate cut. Scalpers finish their
// release, while a lethal UFO keeps its victim held during the readable beat.
var game_over_player = instance_find(obj_player, 0);
if (game_over_player != noone && game_over_player.player_dead)
{
    world_scroll_delta = 0;

    // A lethal UFO capture deliberately keeps the player inside the claw.
    // Unlike the Scalpers, it does not need to release before the delay runs.
    var lethal_ufo_hold = game_over_player.ufo_captured
        && game_over_player.player_last_damage_cause
            == PlayerDamageCause.UFO;

    if (
        (!game_over_player.ufo_captured || lethal_ufo_hold)
        && !game_over_player.scalper_captured
    )
    {
        game_over_wait_timer += delta_seconds;
    }

    if (game_over_wait_timer >= game_over_hurt_duration)
    {
        if (!instance_exists(obj_gameover))
            instance_create_layer(0, 0, "Gameover", obj_gameover);
    }

    exit;
}

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

var lockon_is_clear = !instance_exists(obj_ufo_catcher)
    && !instance_exists(obj_key_pusher);
var lockon_support_hazards_clear = !instance_exists(obj_coin)
    && !instance_exists(obj_walking_duck);
var key_pressed = keyboard_check_pressed(ord("K"));
var ufo_pressed = keyboard_check_pressed(ord("U"));

// The timer advances even while an encounter is active. UFO and Key Pusher
// never overlap one another, and automatic encounters prefer alternation.
lockon_spawn_timer = max(0, lockon_spawn_timer - delta_seconds);

if (lockon_is_clear)
{
    var forced_type = 0;
    if (ufo_pressed) forced_type = 1;
    else if (key_pressed) forced_type = 2;

    if (lockon_spawn_timer <= 0 && !lockon_support_hazards_clear)
        lockon_support_wait += delta_seconds;
    else if (lockon_support_hazards_clear)
        lockon_support_wait = 0;

    var due_for_auto = !debug_manual_lockon
        && lockon_spawn_timer <= 0
        && (lockon_support_hazards_clear
            || lockon_support_wait >= lockon_support_wait_limit);

    if (forced_type != 0 || due_for_auto)
    {
        var spawn_type = (forced_type != 0)
            ? forced_type
            : ((lockon_last_type == 1) ? 2 : 1);
        var lockon_player = instance_find(obj_player, 0);

        if (spawn_type == 1 && !scr_ufo_has_escape_route(lockon_player))
            spawn_type = 2;

        instance_create_layer(
            0,
            0,
            "Instances",
            (spawn_type == 1) ? obj_ufo_catcher : obj_key_pusher
        );
        lockon_last_type = spawn_type;
        lockon_spawn_timer = random_range(
            lockon_cooldown_min,
            lockon_cooldown_max
        );
        lockon_support_wait = 0;

        // Delay only the next support hazard. An existing coin or duck is
        // allowed to finish while the new lock-on encounter begins.
        coin_spawn_timer = max(coin_spawn_timer, 5);
        duck_spawn_timer = max(duck_spawn_timer, 6);
    }
}

// Keep a continuous obstacle stream. During UFO/Key Pusher attacks, the row
// selector limits each new row to one blocker instead of pausing the stream.
if (blocker_generation_enabled)
{
    blocker_distance_remaining -= world_scroll_delta;

    if (blocker_distance_remaining <= 0)
    {
        var blocker_difficulty = clamp(distance_travelled / 18000, 0, 1);
        var lockon_active = instance_exists(obj_ufo_catcher)
            || instance_exists(obj_key_pusher);
        var blocker_row_mask = scr_blocker_pick_routed_mask(
            blocker_safe_lane,
            blocker_difficulty,
            id,
            blocker_previous_row_mask,
            lockon_active
        );

        scr_blocker_spawn_mask(blocker_row_mask, id);
        blocker_previous_row_mask = blocker_row_mask;
        blocker_rows_spawned += 1;

        // Move the reserved route only to an adjacent lane that is also
        // physically open in the row that was just spawned.
        blocker_safe_lane = scr_blocker_choose_next_safe_lane(
            blocker_safe_lane,
            blocker_row_mask,
            id
        );

        // Preserve fractional carry so frame rate does not change density.
        blocker_distance_remaining += random_range(
            blocker_row_spacing_min,
            blocker_row_spacing_max
        );
    }
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
    var coin_y = -coin_spawn_buffer;
    var coin_candidates = [];

    // Use inner lanes so the tower can fall sideways. A candidate is valid
    // only when its arrival area and at least one adjacent lane are clear.
    for (var coin_lane_check = 1;
        coin_lane_check < blocker_lane_count - 1;
        coin_lane_check++)
    {
        var coin_candidate_x = blocker_lane_left
            + (coin_lane_check + 0.5) * blocker_lane_width;
        var coin_candidate_clear = collision_rectangle(
            coin_candidate_x - blocker_lane_width * 0.5,
            coin_y - sprite_get_height(spr_coins),
            coin_candidate_x + blocker_lane_width * 0.5,
            coin_y + blocker_lane_width,
            par_scrolling_blocker,
            false,
            true
        ) == noone;

        var coin_left_escape_x = coin_candidate_x - blocker_lane_width;
        var coin_right_escape_x = coin_candidate_x + blocker_lane_width;
        var coin_left_escape_clear = collision_rectangle(
            coin_left_escape_x - blocker_lane_width * 0.5,
            coin_y - sprite_get_height(spr_coins),
            coin_left_escape_x + blocker_lane_width * 0.5,
            coin_y + blocker_lane_width,
            par_scrolling_blocker,
            false,
            true
        ) == noone;
        var coin_right_escape_clear = collision_rectangle(
            coin_right_escape_x - blocker_lane_width * 0.5,
            coin_y - sprite_get_height(spr_coins),
            coin_right_escape_x + blocker_lane_width * 0.5,
            coin_y + blocker_lane_width,
            par_scrolling_blocker,
            false,
            true
        ) == noone;

        if (
            coin_candidate_clear
            && (coin_left_escape_clear || coin_right_escape_clear)
        ) array_push(coin_candidates, coin_lane_check);
    }

    // If both inner lanes are obstructed, leave the timer due and retry on a
    // later step instead of forcing the tower into an unsafe formation.
    if (array_length(coin_candidates) > 0)
    {
        var coin_lane = coin_candidates[
            irandom(array_length(coin_candidates) - 1)
        ];
        var coin_x = blocker_lane_left
            + (coin_lane + 0.5) * blocker_lane_width;

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
