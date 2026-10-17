/// Four-row obstacle formations for the measured four-lane play area.
/// Mask bits represent occupied lanes from left to right: 1, 2, 4, 8.

function scr_blocker_pattern_data()
{
    return [
        // Tier 0: one-lane rows with generous routes.
        { name: "Classic sweep",      tier: 0, rows: [1, 2, 4, 8] },
        { name: "Reverse sweep",      tier: 0, rows: [8, 4, 2, 1] },
        { name: "Left drift",         tier: 0, rows: [1, 1, 2, 2] },
        { name: "Right drift",        tier: 0, rows: [8, 8, 4, 4] },
        { name: "Diagonal bounce",    tier: 0, rows: [2, 1, 2, 4] },
        { name: "Opposite bounce",    tier: 0, rows: [4, 8, 4, 2] },
        { name: "Wide zigzag",        tier: 0, rows: [1, 4, 2, 8] },
        { name: "Reverse zigzag",     tier: 0, rows: [8, 2, 4, 1] },
        { name: "Left-side return",   tier: 0, rows: [1, 2, 2, 1] },
        { name: "Right-side return",  tier: 0, rows: [8, 4, 4, 8] },
        { name: "Middle drift left",  tier: 0, rows: [2, 2, 4, 4] },
        { name: "Middle drift right", tier: 0, rows: [4, 4, 2, 2] },
        { name: "Left cross",         tier: 0, rows: [1, 4, 8, 4] },
        { name: "Right cross",        tier: 0, rows: [8, 2, 1, 2] },

        // Tier 1: one outer-pair or two-lane row per formation.
        { name: "Pair then staircase", tier: 1, rows: [9, 1, 2, 4] },
        { name: "Left pair surprise",  tier: 1, rows: [1, 9, 8, 4] },
        { name: "Centre switch",       tier: 1, rows: [2, 4, 9, 1] },
        { name: "Late pair",           tier: 1, rows: [8, 4, 2, 9] },
        { name: "Cross then pair",     tier: 1, rows: [4, 9, 1, 2] },
        { name: "Reverse before pair", tier: 1, rows: [2, 1, 9, 8] },
        { name: "Pair to left",        tier: 1, rows: [9, 4, 2, 1] },
        { name: "Pair to right",       tier: 1, rows: [1, 2, 8, 9] },
        { name: "Right to pair",       tier: 1, rows: [4, 8, 9, 2] },
        { name: "Side switch pair",    tier: 1, rows: [8, 9, 4, 1] },
        { name: "Middle then pair",    tier: 1, rows: [2, 9, 4, 8] },
        { name: "Long return",         tier: 1, rows: [4, 1, 9, 8] },
        { name: "Left then middle",    tier: 1, rows: [1, 4, 9, 2] },
        { name: "Right then middle",   tier: 1, rows: [8, 2, 9, 4] },
        { name: "Pair centre exit",    tier: 1, rows: [9, 2, 4, 8] },
        { name: "Late right pair",     tier: 1, rows: [4, 9, 8, 1] },
        { name: "Long diagonal pair",  tier: 1, rows: [2, 8, 1, 9] },
        { name: "Edge-to-edge pair",   tier: 1, rows: [8, 1, 4, 9] },

        // Tier 2: two separated pressure rows.
        { name: "Double gap A",        tier: 2, rows: [9, 1, 9, 4] },
        { name: "Double gap B",        tier: 2, rows: [2, 9, 8, 9] },
        { name: "Long double pair",    tier: 2, rows: [9, 4, 2, 9] },
        { name: "Crossing double",     tier: 2, rows: [1, 9, 4, 9] },
        { name: "Pair bounce",         tier: 2, rows: [9, 8, 9, 2] },
        { name: "Reverse pair bounce", tier: 2, rows: [4, 9, 1, 9] },
        { name: "Late double A",       tier: 2, rows: [9, 2, 8, 9] },
        { name: "Late double B",       tier: 2, rows: [9, 4, 9, 1] },

        // Mixed formations use one two-lane obstacle for masks 3, 6 and 12.
        { name: "Inner pressure",       tier: 1, rows: [2, 6, 8, 4] },
        { name: "Outer pressure",       tier: 1, rows: [1, 3, 4, 8] },
        { name: "Centre crossfade",     tier: 1, rows: [4, 6, 2, 8] },
        { name: "Offset staircase",     tier: 1, rows: [1, 2, 6, 8] },
        { name: "Late inner pair",      tier: 1, rows: [8, 4, 12, 2] },
        { name: "Left feint",           tier: 1, rows: [2, 1, 3, 4] },
        { name: "Right feint",          tier: 1, rows: [4, 8, 12, 2] },
        { name: "Mixed squeeze A",      tier: 2, rows: [9, 6, 1, 12] },
        { name: "Mixed squeeze B",      tier: 2, rows: [3, 8, 9, 2] },
        { name: "Alternating pressure", tier: 2, rows: [6, 1, 12, 4] },
        { name: "Feint and escape",     tier: 2, rows: [3, 4, 9, 2] },
        { name: "Outer inner outer",    tier: 2, rows: [9, 6, 8, 3] }
    ];
}

function scr_blocker_pattern_was_recent(_pattern_id, _recent_ids)
{
    for (var recent_index = 0;
        recent_index < array_length(_recent_ids);
        recent_index++)
    {
        if (_recent_ids[recent_index] == _pattern_id)
        {
            return true;
        }
    }

    return false;
}

function scr_blocker_pick_pattern(_patterns, _difficulty, _recent_ids)
{
    var tier_roll = random(1);
    var wanted_tier = 0;

    if (_difficulty < 0.30)
    {
        if (tier_roll < 0.68) wanted_tier = 0;
        else if (tier_roll < 0.97) wanted_tier = 1;
        else wanted_tier = 2;
    }
    else if (_difficulty < 0.70)
    {
        if (tier_roll < 0.38) wanted_tier = 0;
        else if (tier_roll < 0.90) wanted_tier = 1;
        else wanted_tier = 2;
    }
    else
    {
        if (tier_roll < 0.20) wanted_tier = 0;
        else if (tier_roll < 0.75) wanted_tier = 1;
        else wanted_tier = 2;
    }

    var candidates = [];
    for (var pattern_index = 0;
        pattern_index < array_length(_patterns);
        pattern_index++)
    {
        if (
            _patterns[pattern_index].tier == wanted_tier
            && !scr_blocker_pattern_was_recent(pattern_index, _recent_ids)
        )
        {
            array_push(candidates, pattern_index);
        }
    }

    // A tier should always have candidates, but fall back safely if future
    // edits make the recent-history window larger than a tier.
    if (array_length(candidates) == 0)
    {
        for (var fallback_index = 0;
            fallback_index < array_length(_patterns);
            fallback_index++)
        {
            if (!scr_blocker_pattern_was_recent(fallback_index, _recent_ids))
            {
                array_push(candidates, fallback_index);
            }
        }
    }

    return candidates[irandom(array_length(candidates) - 1)];
}

function scr_blocker_mirror_mask(_mask)
{
    switch (_mask)
    {
        case 1: return 8;
        case 2: return 4;
        case 4: return 2;
        case 8: return 1;
        case 3: return 12;
        case 12: return 3;
    }

    return _mask;
}

function scr_blocker_pick_one_lane_object()
{
    return choose(obj_blocker1, obj_blocker2);
}

function scr_blocker_spawn_in_lanes(
    _object,
    _lane_start,
    _lane_span,
    _controller
)
{
    var blocker_sprite = object_get_sprite(_object);
    if (blocker_sprite < 0)
    {
        return noone;
    }

    var blocker_height = sprite_get_height(blocker_sprite);
    var blocker_bottom_from_origin = blocker_height
        - sprite_get_yoffset(blocker_sprite);
    var spawn_x = _controller.blocker_lane_left
        + (_lane_start + _lane_span * 0.5)
            * _controller.blocker_lane_width;
    var spawn_y = -blocker_bottom_from_origin
        - _controller.blocker_spawn_buffer;
    var spawned_blocker = instance_create_layer(
        spawn_x,
        spawn_y,
        "Obstacles",
        _object
    );

    if (spawned_blocker != noone)
    {
        // Preserve the authored property while making the intended footprint
        // explicit for generated rows.
        spawned_blocker.lane_occupy = _lane_span;
    }

    return spawned_blocker;
}

function scr_blocker_spawn_mask(_mask, _controller)
{
    switch (_mask)
    {
        case 0:
            return;

        case 1:
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 0, 1, _controller
            );
            return;

        case 2:
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 1, 1, _controller
            );
            return;

        case 4:
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 2, 1, _controller
            );
            return;

        case 8:
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 3, 1, _controller
            );
            return;

        case 3:
            scr_blocker_spawn_in_lanes(obj_blocker3, 0, 2, _controller);
            return;

        case 6:
            scr_blocker_spawn_in_lanes(obj_blocker3, 1, 2, _controller);
            return;

        case 12:
            scr_blocker_spawn_in_lanes(obj_blocker3, 2, 2, _controller);
            return;

        case 9:
            // Two one-lane edge obstacles preserve both centre lanes.
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 0, 1, _controller
            );
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 3, 1, _controller
            );
            return;
    }

    // Unknown masks degrade to a safe single obstacle.
    scr_blocker_spawn_in_lanes(
        scr_blocker_pick_one_lane_object(), irandom(3), 1, _controller
    );
}
