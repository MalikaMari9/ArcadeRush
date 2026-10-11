// Scrolling blockers push the player downward after all normal movement.
var run_controller = instance_find(obj_controller, 0);

if (
    !ufo_captured
    && run_controller != noone
    && run_controller.world_scroll_delta > 0
    && place_meeting(x, y, par_scrolling_blocker)
)
{
    var push_step = min(1, run_controller.world_scroll_delta);
    var push_attempts = ceil(run_controller.world_scroll_delta / push_step) + 2;

    var mask_bottom_offset = bbox_bottom - y;
    var maximum_y = (room_height - 1) - mask_bottom_offset;

    repeat (push_attempts)
    {
        if (!place_meeting(x, y, par_scrolling_blocker))
        {
            break;
        }

        var next_y = min(y + push_step, maximum_y);

        if (next_y <= y)
        {
            break;
        }

        y = next_y;
    }
}
// Sort by the player's feet so tall obstacle artwork can draw in front.
depth = -bbox_bottom;
