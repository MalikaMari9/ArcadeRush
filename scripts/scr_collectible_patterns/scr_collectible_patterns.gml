/// @description Row-synchronised, fair ticket trails and automatic power-ups.
/// All pickups move with the world through their existing parent Step events.
/// Spawning just behind a newly created obstacle row keeps collectible trails
/// between blocker rows, so future rows cannot appear over the pickups.

function scr_collectible_lane_centre(_lane, _controller)
{
    return _controller.blocker_lane_left
        + (_lane + 0.5) * _controller.blocker_lane_width;
}

// Use the *actual* blocker collision bounds, not merely a lane-bit check.
// A lane must be wide enough for the player through both bordering rows.
function scr_collectible_clear_lanes(_controller, _current_mask, _previous_mask)
{
    var lanes = [];
    for (var lane = 0; lane < _controller.blocker_lane_count; lane++)
    {
        if (
            scr_blocker_lane_is_safe(_current_mask, lane, _controller)
            && (_previous_mask == 0 || scr_blocker_lane_is_safe(
                _previous_mask, lane, _controller
            ))
        )
        {
            array_push(lanes, lane);
        }
    }
    return lanes;
}

// Check actual positions in addition to the routed geometry. This catches
// different obstacle heights, existing pickups, and an active coin tower.
function scr_collectible_space_clear(_x, _y, _half_w, _half_h, _padding)
{
    var left = _x - _half_w - _padding;
    var right = _x + _half_w + _padding;
    var top = _y - _half_h - _padding;
    var bottom = _y + _half_h + _padding;

    if (
        collision_rectangle(left, top, right, bottom,
            par_scrolling_blocker, false, true) != noone
        || collision_rectangle(left, top, right, bottom,
            obj_coin, false, true) != noone
        || collision_rectangle(left, top, right, bottom,
            par_powerup, false, true) != noone
        || collision_rectangle(left, top, right, bottom,
            par_ticket, false, true) != noone
    ) return false;
    return true;
}

function scr_collectible_pick_powerup(_controller)
{
    var player = instance_find(obj_player, 0);
    var weights = [3.3, 3.3, 3.4]; // Magnet, Double Ticket, Shield.

    if (player != noone)
    {
        if (player.ticket_magnet_timer > 3) weights[0] *= 0.35;
        if (player.ticket_double_timer > 3) weights[1] *= 0.35;
        if (player.powerup_shield_timer > 0) weights[2] *= 0.18;
        else if (player.player_lives == 1) weights[2] *= 1.55;
    }

    // Discourage repeats without making any of the three impossible.
    if (_controller.powerup_last_kind >= 0)
        weights[_controller.powerup_last_kind] *= 0.33;

    var total = weights[0] + weights[1] + weights[2];
    var roll = random(total);
    if (roll < weights[0]) return 0;
    if (roll < weights[0] + weights[1]) return 1;
    return 2;
}

// Return true only if a reachable, visually clear power-up was placed.
function scr_collectible_try_powerup(_controller, _lanes)
{
    if (
        _controller.powerup_distance_remaining > 0
        || instance_number(par_powerup) >= _controller.powerup_active_max
        || array_length(_lanes) == 0
    ) return false;

    var sprites = [spr_magnet_anim, spr_double_ticket, spr_shield];
    var objects = [obj_powerup_magnet, obj_powerup_doubleticket,
        obj_powerup_shield];
    var kind = scr_collectible_pick_powerup(_controller);
    var chosen_sprite = sprites[kind];
    var size = _controller.powerup_sprite_scale;
    var half_w = sprite_get_width(chosen_sprite) * size * 0.5;
    var half_h = sprite_get_height(chosen_sprite) * size * 0.5;
    var player = instance_find(obj_player, 0);

    // Nearest clear lanes receive a small preference, but another lane can
    // win, so rewards do not always form immediately above the runner.
    var total_weight = 0;
    var chosen_lane = -1;
    var chosen_x = 0;
    // Keep the complete scaled pickup above the room so it scrolls into view
    // instead of popping into existence around the top edge.
    var spawn_y = -half_h
        - _controller.powerup_spawn_buffer
        - random_range(0, 24);

    for (var index = 0; index < array_length(_lanes); index++)
    {
        var lane = _lanes[index];
        var spawn_x = scr_collectible_lane_centre(lane, _controller)
            + random_range(-16, 16);
        if (!scr_collectible_space_clear(
            spawn_x, spawn_y, half_w, half_h, _controller.powerup_clearance
        )) continue;

        var weight = 1;
        if (player != noone)
            weight = 1 + 0.65 * (1 - min(1,
                abs(spawn_x - player.x) / (_controller.blocker_lane_width * 3)));
        total_weight += weight;
        if (random(total_weight) < weight)
        {
            chosen_lane = lane;
            chosen_x = spawn_x;
        }
    }

    if (chosen_lane < 0) return false;

    var pickup = instance_create_layer(
        chosen_x, spawn_y, "powerup", objects[kind]
    );
    if (pickup == noone) return false;
    pickup.image_xscale = size;
    pickup.image_yscale = size;
    _controller.powerup_last_kind = kind;
    _controller.powerup_distance_remaining = random_range(
        _controller.powerup_spacing_min, _controller.powerup_spacing_max
    );
    return true;
}

// Pick a *whole* valid trail, not the first valid lane in a random rotation.
// Recent lane heat makes tickets spread across left, middle and right while
// keeping every item clear of the real obstacles and other collectibles.
function scr_collectible_try_ticket_trail(_controller, _lanes)
{
    if (array_length(_lanes) == 0) return false;
    if (instance_number(par_ticket) >= _controller.ticket_active_max - 4)
        return false;

    var segment_roll = irandom(99);
    var count = 2;
    if (segment_roll >= 84) count = 5;
    else if (segment_roll >= 52) count = 4;
    else if (segment_roll >= 20) count = 3;

    if (instance_number(par_ticket) + count > _controller.ticket_active_max)
        return false;

    // Shapes: almost straight, soft weave, adjacent-lane diagonal, zigzag,
    // and a short curved detour returning to the same lane.
    var chosen_style = irandom(4);
    if (chosen_style == _controller.ticket_last_style)
        chosen_style = (chosen_style + irandom_range(1, 4)) mod 5;

    var half_w = sprite_get_width(spr_ticket_1) * 0.5;
    var half_h = sprite_get_height(spr_ticket_1) * 0.5;
    var gap = _controller.ticket_trail_spacing + random_range(10, 20);
    // Position from the trail's lowest ticket upward. Even a five-ticket
    // formation is therefore fully outside the room on its creation frame.
    var trail_bottom_y = -half_h
        - _controller.ticket_spawn_buffer
        - random_range(0, 14);
    var base_y = trail_bottom_y - (count - 1) * gap;

    var best_lane = -1;
    var best_style = -1;
    var best_x = [];
    var best_y = [];
    var total_weight = 0;

    // Evaluate all safe lanes, including those at the extreme left.
    // Testing first and choosing second prevents placement failures from
    // quietly biasing the result toward the first usable right-side lane.
    for (var lane_index = 0; lane_index < array_length(_lanes); lane_index++)
    {
        var lane = _lanes[lane_index];
        var centre = scr_collectible_lane_centre(lane, _controller);
        var candidate_style = chosen_style;
        var candidate_x = [];
        var candidate_y = [];
        var valid = false;

        // If the selected pattern cannot fit, try an unobtrusive straight
        // trail in this SAME lane before discarding it as a candidate.
        for (var retry = 0; retry < 2 && !valid; retry++)
        {
            candidate_style = (retry == 0) ? chosen_style : 0;
            var endpoint = centre;
            if (candidate_style == 2)
            {
                var neighbours = [];
                for (var neighbour_index = 0;
                    neighbour_index < array_length(_lanes);
                    neighbour_index++)
                {
                    if (abs(_lanes[neighbour_index] - lane) == 1)
                        array_push(neighbours, _lanes[neighbour_index]);
                }
                if (array_length(neighbours) > 0)
                {
                    endpoint = scr_collectible_lane_centre(
                        neighbours[irandom(array_length(neighbours) - 1)],
                        _controller
                    );
                }
                else candidate_style = 0;
            }

            candidate_x = [];
            candidate_y = [];
            valid = true;
            var dir = choose(-1, 1);
            for (var segment = 0; segment < count; segment++)
            {
                var t = segment / max(1, count - 1);
                var trail_x = centre;
                var trail_y = base_y + segment * gap;

                switch (candidate_style)
                {
                    case 0: trail_x += dir * 9; break;
                    case 1: trail_x += sin(t * pi * 2) * 31; break;
                    case 2: trail_x = lerp(centre, endpoint, t); break;
                    case 3:
                        trail_x += ((segment mod 2) * 2 - 1) * 33;
                        break;
                    case 4:
                        trail_x += dir * sin(t * pi) * 43;
                        break;
                }

                if (trail_x - half_w - _controller.ticket_spawn_clearance
                        < _controller.blocker_spawn_left
                    || trail_x + half_w + _controller.ticket_spawn_clearance
                        > _controller.blocker_spawn_right
                    || !scr_collectible_space_clear(
                        trail_x, trail_y, half_w, half_h,
                        _controller.ticket_spawn_clearance
                    ))
                {
                    valid = false;
                    break;
                }
                array_push(candidate_x, trail_x);
                array_push(candidate_y, trail_y);
            }
        }

        if (!valid) continue;

        // Heat decays on each obstacle row. Select cooler lanes more often;
        // penalize the immediately previous lane but never forbid a safe one.
        var heat = _controller.ticket_lane_heat[lane];
        var weight = 1 / (1 + heat * 0.65);
        if (lane == _controller.ticket_last_lane) weight *= 0.25;

        total_weight += weight;
        if (random(total_weight) < weight)
        {
            best_lane = lane;
            best_style = candidate_style;
            best_x = candidate_x;
            best_y = candidate_y;
        }
    }

    if (best_lane < 0) return false;

    for (var i = 0; i < count; i++)
    {
        var roll = irandom(99);
        var ticket_object = obj_ticket_1;
        if (roll >= 95 || (i == count - 1 && roll >= 88))
            ticket_object = obj_ticket_5;
        else if (roll >= 70)
            ticket_object = obj_ticket_2;

        instance_create_layer(best_x[i], best_y[i], "Tickets", ticket_object);
    }

    _controller.ticket_lane_heat[best_lane] += 1.3;
    _controller.ticket_last_lane = best_lane;
    _controller.ticket_last_style = best_style;
    return true;
}

// Called after spawning EACH new blocker row. Generating rewards as part of
// the same distance section prevents the old arbitrary top-of-screen overlap
// and ties the safe collectible trail to the physical obstacle route.
function scr_collectible_spawn_for_row(_controller, _mask, _previous_mask)
{
    // Recent history rather than lifetime totals: recover quickly if the
    // obstacle layout temporarily makes one half unavailable.
    for (var heat_lane = 0; heat_lane < _controller.blocker_lane_count;
        heat_lane++)
    {
        _controller.ticket_lane_heat[heat_lane] *= 0.85;
    }

    var safe_lanes = scr_collectible_clear_lanes(
        _controller, _mask, _previous_mask
    );

    if (scr_collectible_try_powerup(_controller, safe_lanes))
    {
        // Give a rare pickup its own readable lane; the next row is likely
        // to contain tickets, especially useful after Double Ticket.
        _controller.ticket_rows_since_spawn = max(
            2, _controller.ticket_rows_since_spawn
        );
        return;
    }

    var difficulty = clamp(_controller.distance_travelled / 18000, 0, 1);
    var chance = lerp(0.76, 0.86, difficulty);
    if (_controller.ticket_rows_since_spawn >= 2) chance = 1;

    if (random(1) < chance
        && scr_collectible_try_ticket_trail(_controller, safe_lanes))
    {
        _controller.ticket_rows_since_spawn = 0;
    }
    else
    {
        _controller.ticket_rows_since_spawn += 1;
    }
}
