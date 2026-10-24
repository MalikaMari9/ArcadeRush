// The sign intentionally sits above the opening sequence, unlike the menu
// buttons. It shares their frame-200 handoff so it does not linger afterward.
if (opening_playing)
{
    var opening_sign_visible = layer_sequence_exists(
        opening_layer,
        opening_sequence
    ) && layer_sequence_get_headpos(opening_sequence)
        < opening_menu_hide_frame;

    if (!opening_sign_visible)
    {
        exit;
    }
}

draw_sprite(spr_sign, 0, menu_sign_x, menu_sign_y);
