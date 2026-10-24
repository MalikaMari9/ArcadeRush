menu_button_x = 549;
menu_button_y = [1250, 1460, 1670];
menu_button_width = 360;
menu_button_height = 105;
menu_button_labels = ["START", "SETTINGS", "HOW TO PLAY"];

menu_hovered_button = -1;
menu_pressed_button = -1;
menu_status_text = "";
menu_status_timer = 0;

// The opening sequence is created only after Start is selected. While it is
// playing, this object keeps the start room alive but hides/disables its GUI.
opening_playing = false;
opening_layer = -1;
opening_sequence = -1;
opening_menu_hide_frame = 200;

// Saved positions from the start room's temporary Debug asset layer.
menu_sign_x = 256;
menu_sign_y = 1026;
