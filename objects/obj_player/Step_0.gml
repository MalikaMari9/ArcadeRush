// The catcher owns the player's position until it releases them.
if (ufo_captured)
{
    exit;
}

// Read WASD input as a two-dimensional player movement vector.
var input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

// Normalize input so diagonal movement is not faster.
var input_length = sqrt(input_x * input_x + input_y * input_y);

if (input_length > 0)
{
    input_x /= input_length;
    input_y /= input_length;
}

var delta_seconds = delta_time / 1000000;

var move_x = input_x * move_speed * delta_seconds;
var move_y = input_y * move_speed * delta_seconds;

// Resolve horizontal movement first. Sub-pixel steps prevent tunneling.
if (move_x != 0)
{
    var horizontal_steps = ceil(abs(move_x));
    var horizontal_step = move_x / horizontal_steps;

    repeat (horizontal_steps)
    {
        if (!place_meeting(x + horizontal_step, y, par_blocker))
        {
            x += horizontal_step;
        }
        else
        {
            break;
        }
    }
}

// Resolve vertical movement separately so the player slides along walls.
if (move_y != 0)
{
    var vertical_steps = ceil(abs(move_y));
    var vertical_step = move_y / vertical_steps;

    repeat (vertical_steps)
    {
        if (!place_meeting(x, y + vertical_step, par_blocker))
        {
            y += vertical_step;
        }
        else
        {
            break;
        }
    }
}

// Keep the player's complete collision mask inside the room.
var mask_left_offset = bbox_left - x;
var mask_right_offset = bbox_right - x;
var mask_top_offset = bbox_top - y;
var mask_bottom_offset = bbox_bottom - y;

x = clamp(
    x,
    -mask_left_offset,
    (room_width - 1) - mask_right_offset
);

y = clamp(
    y,
    -mask_top_offset,
    (room_height - 1) - mask_bottom_offset
);
