menu_hovered_button = -1;
menu_pressed_button = -1;

// Wait for the sequence itself to finish instead of using a separate timer.
if (opening_playing)
{
    if (layer_sequence_exists(opening_layer, opening_sequence))
    {
        if (layer_sequence_is_finished(opening_sequence))
        {
            room_goto(rm_gameRoom);
        }
    }

    exit;
}

var start_requested = false;

var pointer_x = device_mouse_x_to_gui(0);
var pointer_y = device_mouse_y_to_gui(0);
var half_width = menu_button_width * 0.5;
var half_height = menu_button_height * 0.5;

for (var button_index = 0;
    button_index < array_length(menu_button_y);
    button_index++)
{
    var button_y = menu_button_y[button_index];
    if (point_in_rectangle(
        pointer_x,
        pointer_y,
        menu_button_x - half_width,
        button_y - half_height,
        menu_button_x + half_width,
        button_y + half_height
    ))
    {
        menu_hovered_button = button_index;
        break;
    }
}

if (
    menu_hovered_button >= 0
    && device_mouse_check_button_pressed(0, mb_left)
)
{
    menu_pressed_button = menu_hovered_button;

    switch (menu_pressed_button)
    {
        case 0:
            start_requested = true;
            break;

        case 1:
            menu_status_text = "SETTINGS COMING SOON";
            menu_status_timer = 1.5;
            break;

        case 2:
            menu_status_text = "HOW TO PLAY COMING SOON";
            menu_status_timer = 1.5;
            break;
    }
}

// Keyboard support is useful while testing the room on desktop.
if (keyboard_check_pressed(vk_enter))
{
    start_requested = true;
}

if (start_requested)
{
    // A temporary high-priority room layer keeps the sequence above all
    // normal start-room artwork. Draw GUI is hidden separately below.
    opening_layer = layer_create(-10000, "OpeningSequence");
    opening_sequence = layer_sequence_create(
        opening_layer,
        room_width * 0.5,
        room_height * 0.5,
        seq_opening
    );
    opening_playing = true;
    menu_hovered_button = -1;
    menu_pressed_button = -1;
    menu_status_text = "";
    menu_status_timer = 0;
    exit;
}

menu_status_timer = max(
    0,
    menu_status_timer - min(delta_time / 1000000, 1 / 15)
);
if (menu_status_timer <= 0)
{
    menu_status_text = "";
}
