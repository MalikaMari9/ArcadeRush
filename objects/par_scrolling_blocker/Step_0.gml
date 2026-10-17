// All world blockers use the same controller-owned scroll amount.
var run_controller = instance_find(obj_controller, 0);

if (run_controller == noone)
{
    exit;
}

var move_y = max(0, run_controller.world_scroll_delta);

if (move_y > 0)
{
    var move_steps = ceil(move_y);
    var move_step = move_y / move_steps;

    repeat (move_steps)
    {
        var player_hit = instance_place(x, y + move_step, obj_player);

        if (
            player_hit != noone
            && !player_hit.ufo_captured
            && !player_hit.scalper_captured
            && !player_hit.phase_through_obstacles
        )
        {
            var player_bottom_offset = player_hit.bbox_bottom - player_hit.y;
            var player_maximum_y = (room_height - 1) - player_bottom_offset;

            // Do not enter the player if the room edge prevents the push.
            if (player_hit.y + move_step > player_maximum_y)
            {
                break;
            }

            player_hit.y += move_step;
        }

        y += move_step;
    }
}

// Sort by the collision base. Blockers win ties so their upper artwork
// covers the player when both stand on the same visual baseline.
depth = -bbox_bottom - 1;

// Remove blockers only after their complete collision mask leaves the room.
if (bbox_top > room_height + 64)
{
    instance_destroy();
}
