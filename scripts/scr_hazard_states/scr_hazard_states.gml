enum UfoState
{
    ENTER,
    TRACK,
    LOCKED_WARNING,
    EXTEND,
    ENVELOP,
    CLOSE,
    RETRACT,
    EXIT
}

enum KeyPusherState
{
    TRACK,
    LOCKED_WARNING,
    FALLING,
    IMPACT
}

// Conservative scheduler check: an automatic UFO is allowed only when the
// player has a clear straight or diagonal route away from its sweep row.
function scr_ufo_has_escape_route(_player)
{
    if (_player == noone || !instance_exists(_player)) return false;
    if (
        _player.ufo_captured
        || _player.scalper_captured
        || _player.invulnerable
    ) return false;

    var escape_distance = 220;
    var lane_left = 128;
    var lane_right = 960;
    var controller = instance_find(obj_controller, 0);
    if (controller != noone)
    {
        lane_left = controller.blocker_spawn_left;
        lane_right = controller.blocker_spawn_right;
    }

    var left_offset = _player.bbox_left - _player.x;
    var right_offset = _player.bbox_right - _player.x;
    var top_offset = _player.bbox_top - _player.y;
    var bottom_offset = _player.bbox_bottom - _player.y;
    var vertical_options = [-escape_distance, escape_distance];
    var horizontal_options = [0, -160, 160];

    for (var horizontal_index = 0;
        horizontal_index < array_length(horizontal_options);
        horizontal_index++)
    {
        var target_x = _player.x + horizontal_options[horizontal_index];
        if (
            target_x + left_offset < lane_left
            || target_x + right_offset > lane_right
        ) continue;

        for (var vertical_index = 0;
            vertical_index < array_length(vertical_options);
            vertical_index++)
        {
            var target_y = _player.y + vertical_options[vertical_index];
            if (
                target_y + top_offset < 0
                || target_y + bottom_offset >= room_height
            ) continue;

            if (
                collision_line(
                    _player.x,
                    _player.y,
                    target_x,
                    target_y,
                    par_scrolling_blocker,
                    false,
                    true
                ) == noone
                && collision_rectangle(
                    target_x + left_offset,
                    target_y + top_offset,
                    target_x + right_offset,
                    target_y + bottom_offset,
                    par_scrolling_blocker,
                    false,
                    true
                ) == noone
            ) return true;
        }
    }

    return false;
}
