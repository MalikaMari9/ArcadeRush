var old_colour = draw_get_colour();
var old_alpha = draw_get_alpha();
var old_halign = draw_get_halign();
var old_valign = draw_get_valign();
var old_font = draw_get_font();

var heading_colour = make_colour_rgb(114, 103, 157);
var score_colour = make_colour_rgb(63, 106, 142);
var ticket_colour = make_colour_rgb(183, 87, 143);
var border_colour = make_colour_rgb(181, 157, 211);
var fill_colour = make_colour_rgb(252, 247, 255);
var shadow_colour = make_colour_rgb(91, 69, 133);

draw_set_font(fnt_default);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(1);

// Numeric placements copied from the hidden debug guides.
draw_set_colour(score_colour);
draw_text(876.5, 371, score_high_text);
draw_text(636, 460, score_plays_text);
draw_text(737, 576, score_current_text);

// Current-run breakdown within the large lower guide.
var row_x = 538;
var label_scale = 1.25;
var value_scale = 1.65;

draw_set_colour(heading_colour);
draw_text_transformed(row_x, 900, "SCORE", label_scale, label_scale, 0);
draw_set_colour(score_colour);
draw_text_transformed(
    row_x,
    980,
    score_current_text,
    value_scale,
    value_scale,
    0
);

draw_set_colour(heading_colour);
draw_text_transformed(row_x, 1110, "DISTANCE", label_scale, label_scale, 0);
draw_set_colour(score_colour);
draw_text_transformed(
    row_x,
    1190,
    score_distance_text + " m",
    value_scale,
    value_scale,
    0
);

draw_set_colour(heading_colour);
draw_text_transformed(row_x, 1320, "TICKETS", label_scale, label_scale, 0);
draw_set_colour(ticket_colour);
draw_text_transformed(
    row_x,
    1400,
    score_ticket_text,
    value_scale,
    value_scale,
    0
);

var half_width = score_button_width * 0.5;
var half_height = score_button_height * 0.5;

for (var button_index = 0;
    button_index < array_length(score_button_x);
    button_index++)
{
    var button_x = score_button_x[button_index];
    var hovered = button_index == score_hovered_button;
    var pressed = button_index == score_pressed_button;
    var button_scale = pressed ? 0.96 : (hovered ? 1.04 : 1);
    var scaled_half_width = half_width * button_scale;
    var scaled_half_height = half_height * button_scale;
    var left = button_x - scaled_half_width;
    var right = button_x + scaled_half_width;
    var top = score_button_y - scaled_half_height;
    var bottom = score_button_y + scaled_half_height;

    draw_set_alpha(hovered ? 0.18 : 0.12);
    draw_set_colour(shadow_colour);
    draw_roundrect(left + 4, top + 5, right + 4, bottom + 5, false);

    draw_set_alpha(1);
    draw_set_colour(border_colour);
    draw_roundrect(left, top, right, bottom, false);
    draw_set_colour(fill_colour);
    draw_roundrect(left + 3, top + 3, right - 3, bottom - 3, false);

    draw_set_colour(heading_colour);
    draw_text(button_x, score_button_y, score_button_labels[button_index]);
}

draw_set_colour(old_colour);
draw_set_alpha(old_alpha);
draw_set_halign(old_halign);
draw_set_valign(old_valign);
draw_set_font(old_font);
