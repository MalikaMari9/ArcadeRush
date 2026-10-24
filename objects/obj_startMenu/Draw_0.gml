// Draw on the room layer so the opening sequence can pass over the complete
// start presentation. Keep it visible during the sequence's opening
// beat. At frame 200 its matching sign/character tracks end, so remove this
// menu in sync rather than hiding it as soon as Start is pressed.
if (opening_playing)
{
    var opening_menu_visible = layer_sequence_exists(
        opening_layer,
        opening_sequence
    ) && layer_sequence_get_headpos(opening_sequence)
        < opening_menu_hide_frame;

    if (!opening_menu_visible)
    {
        exit;
    }
}

var old_colour = draw_get_colour();
var old_alpha = draw_get_alpha();
var old_halign = draw_get_halign();
var old_valign = draw_get_valign();
var old_font = draw_get_font();

var button_border = make_colour_rgb(181, 157, 211);
var button_fill = make_colour_rgb(252, 247, 255);
var button_text = make_colour_rgb(114, 103, 157);
var button_shadow = make_colour_rgb(91, 69, 133);
var half_width = menu_button_width * 0.5;
var half_height = menu_button_height * 0.5;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_default);

for (var button_index = 0;
    button_index < array_length(menu_button_y);
    button_index++)
{
    var button_y = menu_button_y[button_index];
    var hovered = button_index == menu_hovered_button;
    var pressed = button_index == menu_pressed_button;
    var scale = pressed ? 0.96 : (hovered ? 1.04 : 1);
    var scaled_half_width = half_width * scale;
    var scaled_half_height = half_height * scale;
    var left = menu_button_x - scaled_half_width;
    var right = menu_button_x + scaled_half_width;
    var top = button_y - scaled_half_height;
    var bottom = button_y + scaled_half_height;

    draw_set_alpha(hovered ? 0.18 : 0.12);
    draw_set_colour(button_shadow);
    draw_roundrect(left + 4, top + 5, right + 4, bottom + 5, false);

    draw_set_alpha(1);
    draw_set_colour(button_border);
    draw_roundrect(left, top, right, bottom, false);

    draw_set_colour(button_fill);
    draw_roundrect(left + 3, top + 3, right - 3, bottom - 3, false);

    draw_set_colour(button_text);
    var button_label = menu_button_labels[button_index];
    var label_scale = min(
        1,
        (menu_button_width - 32) / max(1, string_width(button_label))
    );
    draw_text_transformed(
        menu_button_x,
        button_y,
        button_label,
        label_scale,
        label_scale,
        0
    );
}

if (menu_status_text != "")
{
    draw_set_alpha(clamp(menu_status_timer, 0, 1));
    draw_set_colour(button_text);
    draw_text_transformed(549, 1830, menu_status_text, 1.5, 1.5, 0);
}

draw_set_colour(old_colour);
draw_set_alpha(old_alpha);
draw_set_halign(old_halign);
draw_set_valign(old_valign);
draw_set_font(old_font);
