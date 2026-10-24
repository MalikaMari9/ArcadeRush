// Shared gameplay time is paused while this UI object uses real frame time.
game_over_time += game_delta_seconds(true);

if (game_over_time >= game_over_retry_delay)
{
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();
    var retry_x = gui_width * 0.5;
    var retry_y = gui_height * 0.5 + 180;
    var retry_half_width = 360 * 0.5;
    var retry_half_height = 105 * 0.5;
    var pointer_x = device_mouse_x_to_gui(0);
    var pointer_y = device_mouse_y_to_gui(0);
    var pointer_inside = point_in_rectangle(
        pointer_x,
        pointer_y,
        retry_x - retry_half_width,
        retry_y - retry_half_height,
        retry_x + retry_half_width,
        retry_y + retry_half_height
    );

    if (
        keyboard_check_pressed(vk_enter)
        || (pointer_inside && mouse_check_button_pressed(mb_left))
    )
    {
        var result_controller = instance_find(obj_controller, 0);
        if (result_controller != noone)
        {
            global.last_run_score = 0;
            global.last_run_distance = floor(
                result_controller.distance_travelled
                    / result_controller.distance_pixels_per_metre
            );
            global.last_run_tickets = result_controller.run_tickets;
        }
        else
        {
            global.last_run_score = 0;
            global.last_run_distance = 0;
            global.last_run_tickets = 0;
        }

        room_goto(rm_roomScore);
        exit;
    }
}
