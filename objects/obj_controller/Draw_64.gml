// Temporary upper-right debug HUD. Tickets remain separate from score.
var distance_metres = floor(
    distance_travelled / distance_pixels_per_metre
);
var run_score = floor(distance_metres * score_per_metre);
var hud_x = display_get_gui_width() - 24;
var hud_y = 24;

draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_set_alpha(1);
draw_text(
    hud_x,
    hud_y,
    "SCORE: " + string(run_score)
        + "\nDISTANCE: " + string(distance_metres) + " m"
        + "\nTICKETS: " + string(run_tickets)
);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
