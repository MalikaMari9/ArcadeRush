// Centered two-stat pastel HUD; the spr_ui_top backdrop remains unchanged.
// GUI coordinates keep the HUD centered at any game-window scale.
var gui_cx = display_get_gui_width() * 0.5;
var distance_metres = floor(distance_travelled / distance_pixels_per_metre);
var card_w = 206;
var card_h = 102;
var card_gap = 16;
var card_top = 22;
var pair_left = gui_cx - (card_w * 2 + card_gap) * 0.5;

var card_border = make_color_rgb(181, 157, 211);
var card_fill = make_color_rgb(252, 247, 255);
var label_color = make_color_rgb(114, 103, 157);
var distance_color = make_color_rgb(63, 106, 142);
var tickets_color = make_color_rgb(183, 87, 143);

for (var card = 0; card < 2; card++)
{
    var left = pair_left + card * (card_w + card_gap);
    var right = left + card_w;
    var centre = left + card_w * 0.5;

    draw_set_alpha(0.12);
    draw_set_color(make_color_rgb(91, 69, 133));
    draw_roundrect(
        left + 4,
        card_top + 5,
        right + 4,
        card_top + card_h + 5,
        false
    );
    draw_set_alpha(1);
    draw_set_color(card_border);
    draw_roundrect(left, card_top, right, card_top + card_h, false);
    draw_set_color(card_fill);
    draw_roundrect(
        left + 3,
        card_top + 3,
        right - 3,
        card_top + card_h - 3,
        false
    );

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(label_color);
    draw_text_transformed(
        centre,
        card_top + 15,
        (card == 0) ? "DISTANCE" : "TICKETS",
        1.55,
        1.55,
        0
    );

    draw_set_color((card == 0) ? distance_color : tickets_color);
    var value_text = (card == 0)
        ? (string(distance_metres) + " m")
        : string(run_tickets);
    draw_text_transformed(
        centre,
        card_top + 46,
        value_text,
        2.55,
        2.55,
        0
    );
}

// Do not leak custom draw settings into the rest of the game UI.
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
