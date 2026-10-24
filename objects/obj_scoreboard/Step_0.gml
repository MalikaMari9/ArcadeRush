score_hovered_button = -1;
score_pressed_button = -1;

var pointer_x = device_mouse_x_to_gui(0);
var pointer_y = device_mouse_y_to_gui(0);
var half_width = score_button_width * 0.5;
var half_height = score_button_height * 0.5;

for (var button_index = 0;
    button_index < array_length(score_button_x);
    button_index++)
{
    if (point_in_rectangle(
        pointer_x,
        pointer_y,
        score_button_x[button_index] - half_width,
        score_button_y - half_height,
        score_button_x[button_index] + half_width,
        score_button_y + half_height
    ))
    {
        score_hovered_button = button_index;
        break;
    }
}

if (
    score_hovered_button >= 0
    && device_mouse_check_button_pressed(0, mb_left)
)
{
    score_pressed_button = score_hovered_button;

    if (score_pressed_button == 0)
        room_goto(rm_gameRoom);
    else
        room_goto(rm_gameStart);

    exit;
}

// Desktop shortcuts mirror the two temporary buttons.
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("R")))
    room_goto(rm_gameRoom);
else if (keyboard_check_pressed(vk_escape))
    room_goto(rm_gameStart);
