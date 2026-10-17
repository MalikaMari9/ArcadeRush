// Scrolling blockers push the player downward after all normal movement.
var run_controller = instance_find(obj_controller, 0);

if (
    !ufo_captured
    && !scalper_captured
    && !phase_through_obstacles
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

// During the bite, draw the player behind the crowd. Otherwise retain the
// normal feet-based sorting used by obstacles.
var drawing_scalpers = instance_find(obj_scalpers, 0);
if (scalper_captured && drawing_scalpers != noone)
{
    depth = drawing_scalpers.depth + 1;
}
else
{
    depth = -bbox_bottom;
}
