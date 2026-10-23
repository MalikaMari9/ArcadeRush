touch_move_x = 0;
touch_move_y = 0;

var touch_player = instance_find(obj_player, 0);
var touch_allowed = touch_player != noone
    && !touch_player.player_dead
    && !touch_player.ufo_captured
    && !touch_player.scalper_captured
    && !instance_exists(obj_gameover);

if (!touch_allowed)
{
    touch_active = false;
    exit;
}

if (
    !touch_active
    && device_mouse_check_button_pressed(touch_device, mb_left)
)
{
    var press_x = device_mouse_x_to_gui(touch_device);
    var press_y = device_mouse_y_to_gui(touch_device);

    if (press_y >= touch_activation_top)
    {
        touch_active = true;
        touch_center_x = press_x;
        touch_center_y = press_y;
        touch_knob_x = press_x;
        touch_knob_y = press_y;
    }
}

if (!touch_active)
{
    exit;
}

if (!device_mouse_check_button(touch_device, mb_left))
{
    touch_active = false;
    exit;
}

var pointer_x = device_mouse_x_to_gui(touch_device);
var pointer_y = device_mouse_y_to_gui(touch_device);
var drag_x = pointer_x - touch_center_x;
var drag_y = pointer_y - touch_center_y;
var drag_distance = point_distance(0, 0, drag_x, drag_y);
var knob_distance = min(drag_distance, touch_radius);

if (drag_distance > 0)
{
    touch_knob_x = touch_center_x
        + drag_x / drag_distance * knob_distance;
    touch_knob_y = touch_center_y
        + drag_y / drag_distance * knob_distance;
}
else
{
    touch_knob_x = touch_center_x;
    touch_knob_y = touch_center_y;
}

if (drag_distance > touch_dead_zone)
{
    var touch_strength = clamp(
        (drag_distance - touch_dead_zone)
            / (touch_radius - touch_dead_zone),
        0,
        1
    );
    touch_move_x = drag_x / drag_distance * touch_strength;
    touch_move_y = drag_y / drag_distance * touch_strength;
}
