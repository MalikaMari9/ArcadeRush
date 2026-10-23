if (!touch_active)
{
    exit;
}

var old_colour = draw_get_colour();
var old_alpha = draw_get_alpha();
var base_colour = make_colour_rgb(181, 157, 211);
var knob_colour = base_colour;

draw_set_colour(base_colour);
draw_set_alpha(0.16);
draw_circle(touch_center_x, touch_center_y, touch_radius, false);

draw_set_alpha(0.58);
for (var base_line = 0; base_line < 5; base_line++)
{
    draw_circle(
        touch_center_x,
        touch_center_y,
        touch_radius - base_line,
        true
    );
}

draw_set_colour(knob_colour);
draw_set_alpha(0.68);
draw_circle(touch_knob_x, touch_knob_y, touch_knob_radius, false);

draw_set_alpha(0.92);
for (var knob_line = 0; knob_line < 5; knob_line++)
{
    draw_circle(
        touch_knob_x,
        touch_knob_y,
        touch_knob_radius - knob_line,
        true
    );
}

draw_set_colour(old_colour);
draw_set_alpha(old_alpha);
