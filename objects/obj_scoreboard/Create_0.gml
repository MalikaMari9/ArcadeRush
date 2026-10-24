// Permanent score/play-count storage will replace these placeholders later.
score_high_text = "000000";
score_plays_text = "000000";
score_current_text = "000000";

var result_distance = variable_global_exists("last_run_distance")
    ? max(0, floor(global.last_run_distance))
    : 0;
var result_tickets = variable_global_exists("last_run_tickets")
    ? max(0, floor(global.last_run_tickets))
    : 0;

var distance_digits = string(result_distance);
var ticket_digits = string(result_tickets);
score_distance_text = string_repeat(
    "0",
    max(0, 6 - string_length(distance_digits))
) + distance_digits;
score_ticket_text = string_repeat(
    "0",
    max(0, 6 - string_length(ticket_digits))
) + ticket_digits;

score_button_x = [315, 765];
score_button_y = 1660;
score_button_width = 360;
score_button_height = 105;
score_button_labels = ["RETRY", "START"];
score_hovered_button = -1;
score_pressed_button = -1;
