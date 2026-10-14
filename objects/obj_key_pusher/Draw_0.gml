var target_scale = key_target_intro_progress;
var impact_alpha = 1;

if (key_state == KeyPusherState.TRACK)
{
    target_scale *= 1 + 0.035 * sin(key_elapsed * 7);
}
else if (key_state == KeyPusherState.LOCKED_WARNING)
{
    target_scale *= 1 + 0.07 * sin(key_elapsed * 18);
}
else if (key_state == KeyPusherState.IMPACT)
{
    impact_alpha = clamp(
        key_state_timer / key_impact_fade_duration,
        0,
        1
    );
}

draw_sprite_ext(
    spr_keymaster_target,
    0,
    key_locked_x + (x - key_locked_x) * (key_state == KeyPusherState.TRACK),
    key_locked_y + (y - key_locked_y) * (key_state == KeyPusherState.TRACK),
    target_scale,
    target_scale,
    0,
    c_white,
    impact_alpha
);
if (key_state >= KeyPusherState.FALLING)
{
    draw_sprite_ext(
        spr_key_master_key,
        0,
        key_locked_x,
        key_y,
        key_scale,
        key_scale,
        0,
        c_white,
        impact_alpha
    );
}