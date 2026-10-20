var ui_player = instance_find(obj_player, 0);
if (ui_player == noone)
{
    exit;
}

var current_lives = clamp(ui_player.player_lives, 0, 3);
var delta_seconds = game_delta_seconds();

ui_portrait_frame = (ui_portrait_frame
    + ui_portrait_fps * delta_seconds) mod 2;

if (ui_previous_lives < 0)
{
    ui_previous_lives = current_lives;
}
else if (current_lives < ui_previous_lives)
{
    // Index 2 is the upper-right heart, 1 is the middle heart, and
    // 0 is the lower-left final heart.
    for (var lost_life = ui_previous_lives;
        lost_life > current_lives; lost_life--)
    {
        var heart_index = lost_life - 1;
        if (heart_index >= 0 && heart_index < 3)
        {
            ui_heart_bursting[heart_index] = true;
            ui_heart_burst_frame[heart_index] = 0;
        }
    }
}
else if (current_lives > ui_previous_lives)
{
    // A reset or debug life increase restores every visible heart.
    for (var reset_index = 0; reset_index < 3; reset_index++)
    {
        ui_heart_bursting[reset_index] = false;
        ui_heart_burst_frame[reset_index] = 0;
    }
}

var frame_count = sprite_get_number(spr_heart_burst_1);

for (var burst_index = 0; burst_index < 3; burst_index++)
{
    if (ui_heart_bursting[burst_index])
    {
        ui_heart_burst_frame[burst_index]
            += ui_heart_burst_fps * delta_seconds;

        if (ui_heart_burst_frame[burst_index] >= frame_count)
        {
            ui_heart_bursting[burst_index] = false;
            ui_heart_burst_frame[burst_index] = 0;
        }
    }
}

ui_previous_lives = current_lives;
