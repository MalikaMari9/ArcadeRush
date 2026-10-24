/// @description Continuous, physically routed blocker-row generation.

function scr_blocker_pick_one_lane_object()
{
    return choose(obj_blocker1, obj_blocker2);
}

function scr_blocker_spawn_in_lanes_offset(
    _object,
    _lane_start,
    _lane_span,
    _controller,
    _x_offset
)
{
    var blocker_sprite = object_get_sprite(_object);
    if (blocker_sprite < 0) return noone;

    var blocker_height = sprite_get_height(blocker_sprite);
    var blocker_bottom_from_origin = blocker_height
        - sprite_get_yoffset(blocker_sprite);
    var spawn_x = _controller.blocker_lane_left
        + (_lane_start + _lane_span * 0.5)
            * _controller.blocker_lane_width
        + _x_offset;
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
        spawned_blocker.lane_occupy = _lane_span;
    }

    return spawned_blocker;
}

function scr_blocker_spawn_in_lanes(
    _object,
    _lane_start,
    _lane_span,
    _controller
)
{
    return scr_blocker_spawn_in_lanes_offset(
        _object,
        _lane_start,
        _lane_span,
        _controller,
        0
    );
}

// Return the real horizontal collision rectangles produced by a row mask.
// obj_blocker1 is conservatively used for one-lane geometry because its mask
// is slightly wider than obj_blocker2's mask.
function scr_blocker_row_rectangles(_mask, _controller)
{
    var components = [];
    var one = obj_blocker1;

    switch (_mask)
    {
        case 1:
            components = [{object_index: one, lane: 0, span: 1, offset: 0}];
            break;
        case 2:
            components = [{object_index: one, lane: 1, span: 1, offset: 0}];
            break;
        case 4:
            components = [{object_index: one, lane: 2, span: 1, offset: 0}];
            break;
        case 8:
            components = [{object_index: one, lane: 3, span: 1, offset: 0}];
            break;
        case 3:
            components = [{object_index: obj_blocker3, lane: 0, span: 2, offset: 0}];
            break;
        case 6:
            components = [{object_index: obj_blocker3, lane: 1, span: 2, offset: 0}];
            break;
        case 12:
            components = [{object_index: obj_blocker3, lane: 2, span: 2, offset: 0}];
            break;
        case 9:
            components = [
                {object_index: one, lane: 0, span: 1, offset: 0},
                {object_index: one, lane: 3, span: 1, offset: 0}
            ];
            break;
        case 7:
            components = [
                {object_index: obj_blocker3, lane: 0, span: 2, offset: 0},
                {object_index: one, lane: 2, span: 1, offset: 8}
            ];
            break;
        case 11:
            components = [
                {object_index: obj_blocker3, lane: 0, span: 2, offset: 0},
                {object_index: one, lane: 3, span: 1, offset: 0}
            ];
            break;
        case 13:
            components = [
                {object_index: one, lane: 0, span: 1, offset: 0},
                {object_index: obj_blocker3, lane: 2, span: 2, offset: 0}
            ];
            break;
        case 14:
            components = [
                {object_index: one, lane: 1, span: 1, offset: -8},
                {object_index: obj_blocker3, lane: 2, span: 2, offset: 0}
            ];
            break;
    }

    var rectangles = [];
    for (var component_index = 0;
        component_index < array_length(components);
        component_index++)
    {
        var component = components[component_index];
        var blocker_sprite = object_get_sprite(component.object_index);
        var centre_x = _controller.blocker_lane_left
            + (component.lane + component.span * 0.5)
                * _controller.blocker_lane_width
            + component.offset;

        array_push(rectangles, {
            left: centre_x + sprite_get_bbox_left(blocker_sprite)
                - sprite_get_xoffset(blocker_sprite),
            right: centre_x + sprite_get_bbox_right(blocker_sprite)
                - sprite_get_xoffset(blocker_sprite)
        });
    }

    return rectangles;
}

function scr_blocker_max_player_width()
{
    return max(
        sprite_get_bbox_right(spr_cat_back_bag)
            - sprite_get_bbox_left(spr_cat_back_bag) + 1,
        sprite_get_bbox_right(spr_cat_back_tag)
            - sprite_get_bbox_left(spr_cat_back_tag) + 1,
        sprite_get_bbox_right(spr_cat_back_body)
            - sprite_get_bbox_left(spr_cat_back_body) + 1
    );
}

// Check a specific lane against the real sprite masks, including five pixels
// of clearance on both sides of the widest player state.
function scr_blocker_lane_is_safe(_mask, _lane, _controller)
{
    if (_lane < 0 || _lane >= _controller.blocker_lane_count) return false;
    if ((floor(_mask / power(2, _lane)) mod 2) != 0) return false;

    var centre_x = _controller.blocker_lane_left
        + (_lane + 0.5) * _controller.blocker_lane_width;
    var half_clearance = scr_blocker_max_player_width() * 0.5 + 5;
    var player_left = centre_x - half_clearance;
    var player_right = centre_x + half_clearance;

    if (
        player_left < _controller.blocker_spawn_left
        || player_right > _controller.blocker_spawn_right
    ) return false;

    var rectangles = scr_blocker_row_rectangles(_mask, _controller);
    for (var rectangle_index = 0;
        rectangle_index < array_length(rectangles);
        rectangle_index++)
    {
        var rectangle = rectangles[rectangle_index];
        if (
            player_left <= rectangle.right
            && player_right >= rectangle.left
        ) return false;
    }

    return true;
}

function scr_blocker_mask_has_escape(_mask, _controller)
{
    if (_mask == 0) return true;
    if (_mask < 0 || _mask >= 15) return false;

    for (var lane = 0; lane < _controller.blocker_lane_count; lane++)
    {
        if (scr_blocker_lane_is_safe(_mask, lane, _controller)) return true;
    }

    return false;
}

// Choose a row that preserves the reserved route. As difficulty rises,
// multi-obstacle rows become more likely. Lock-on attacks force single rows.
function scr_blocker_pick_routed_mask(
    _safe_lane,
    _difficulty,
    _controller,
    _previous_mask,
    _hazard_active
)
{
    var masks = [1, 2, 4, 8, 3, 6, 12, 9, 7, 11, 13, 14];
    var chosen_mask = 0;
    var total_weight = 0;
    var target_lane = _controller.blocker_route_target_lane;
    var toward_target = _safe_lane + sign(target_lane - _safe_lane);

    for (var candidate_index = 0;
        candidate_index < array_length(masks);
        candidate_index++)
    {
        var candidate_mask = masks[candidate_index];
        if (!scr_blocker_lane_is_safe(
            candidate_mask,
            _safe_lane,
            _controller
        )) continue;

        var occupied_lanes = 0;
        for (var lane = 0; lane < _controller.blocker_lane_count; lane++)
        {
            occupied_lanes += floor(
                candidate_mask / power(2, lane)
            ) mod 2;
        }

        if (_hazard_active && occupied_lanes > 1) continue;

        var weight = 1;
        if (occupied_lanes == 1)
            weight = lerp(6, 3.8, _difficulty);
        else if (occupied_lanes == 2)
            weight = lerp(2.5, 5.5, _difficulty);
        else
            weight = lerp(0.2, 1.1, _difficulty);

        if (candidate_mask == _previous_mask) weight *= 0.18;

        // Prefer rows that leave the next adjacent lane physically passable.
        // This is a weighting, not an override of the real hitbox checks.
        // It permits gradual movement between the left and right halves.
        if (toward_target != _safe_lane)
        {
            if (scr_blocker_lane_is_safe(
                candidate_mask, toward_target, _controller
            )) weight *= 3.5;
            else weight *= 0.24;
        }

        total_weight += weight;
        if (random(total_weight) < weight) chosen_mask = candidate_mask;
    }

    if (chosen_mask == 0)
    {
        var lane_to_block = (_safe_lane + 2) mod 4;
        chosen_mask = power(2, lane_to_block);
    }

    return chosen_mask;
}

// Visit both sides of the playfield in short, randomized arcs rather than
// an unbounded random walk (which favors the right because of sprite bounds).
// A lane change happens ONLY when both the old and new lane are open in this
// obstacle row. Never teleport the reserved route through a blocker.
function scr_blocker_choose_next_safe_lane(_lane, _mask, _controller)
{
    var target = _controller.blocker_route_target_lane;
    var chosen_lane = _lane;
    var next_lane = _lane + sign(target - _lane);

    if (next_lane != _lane
        && scr_blocker_lane_is_safe(_mask, next_lane, _controller)
        && random(1) < 0.84)
    {
        chosen_lane = next_lane;
    }

    if (chosen_lane == target)
    {
        _controller.blocker_route_dwell += 1;
        if (_controller.blocker_route_dwell
            >= _controller.blocker_route_dwell_goal)
        {
            // Alternate halves; vary the exact destination for all 4 lanes.
            _controller.blocker_route_target_lane = (target < 2)
                ? irandom_range(2, 3) : irandom_range(0, 1);
            _controller.blocker_route_dwell = 0;
            _controller.blocker_route_dwell_goal = irandom_range(4, 8);
        }
    }
    else
    {
        _controller.blocker_route_dwell = 0;
    }

    return chosen_lane;
}

function scr_blocker_spawn_mask(_mask, _controller)
{
    if (_mask != 0 && !scr_blocker_mask_has_escape(_mask, _controller))
        _mask = choose(1, 2, 4, 8);

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
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 0, 1, _controller
            );
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 3, 1, _controller
            );
            return;
        case 7:
            scr_blocker_spawn_in_lanes(obj_blocker3, 0, 2, _controller);
            scr_blocker_spawn_in_lanes_offset(
                scr_blocker_pick_one_lane_object(), 2, 1, _controller, 8
            );
            return;
        case 11:
            scr_blocker_spawn_in_lanes(obj_blocker3, 0, 2, _controller);
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 3, 1, _controller
            );
            return;
        case 13:
            scr_blocker_spawn_in_lanes(
                scr_blocker_pick_one_lane_object(), 0, 1, _controller
            );
            scr_blocker_spawn_in_lanes(obj_blocker3, 2, 2, _controller);
            return;
        case 14:
            scr_blocker_spawn_in_lanes_offset(
                scr_blocker_pick_one_lane_object(), 1, 1, _controller, -8
            );
            scr_blocker_spawn_in_lanes(obj_blocker3, 2, 2, _controller);
            return;
    }

    scr_blocker_spawn_in_lanes(
        scr_blocker_pick_one_lane_object(), irandom(3), 1, _controller
    );
}
