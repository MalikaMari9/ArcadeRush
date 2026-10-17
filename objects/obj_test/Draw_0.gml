if (debug_lanes_visible)
{
    for (var lane_index = 0; lane_index < debug_lane_count; lane_index++)
    {
        var lane_left = debug_lane_left + lane_index * debug_lane_width;
        var lane_right = lane_left + debug_lane_width;
        var lane_center = (lane_left + lane_right) * 0.5;
        var lane_colour = make_colour_rgb(60, 190, 255);

        draw_set_alpha(0.12);
        draw_set_colour(lane_colour);
        draw_rectangle(lane_left, 0, lane_right, room_height, false);

        draw_set_alpha(0.9);
        draw_rectangle(lane_left, 0, lane_right, room_height - 1, true);
        draw_line_width(lane_center, 0, lane_center, room_height, 2);

        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_text(lane_center, 24, "Lane " + string(lane_index + 1));
        draw_text(lane_center, 52, "X " + string(lane_center));
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
