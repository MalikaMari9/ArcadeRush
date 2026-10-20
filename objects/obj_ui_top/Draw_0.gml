draw_self();

var ui_player = instance_find(obj_player, 0);
if (ui_player == noone)
{
    exit;
}

var ui_lives = clamp(ui_player.player_lives, 0, 3);
var portrait_sprite;

switch (ui_lives)
{
    case 3:
        portrait_sprite = spr_cat_front_bag;
        break;

    case 2:
        portrait_sprite = spr_cat_front_tag;
        break;

    case 1:
    default:
        portrait_sprite = spr_cat_front_body;
        break;
}

// Positions were measured from the temporary Debug asset layer.
draw_sprite(portrait_sprite, floor(ui_portrait_frame), 108, 126);

// Heart index order follows remaining lives: lower-left, middle, upper-right.
var heart_x = [94, 226, 299];
var heart_y = [291, 210, 80];

for (var heart_index = 0; heart_index < 3; heart_index++)
{
    if (heart_index < ui_lives)
    {
        draw_sprite(
            spr_heart_burst_1,
            0,
            heart_x[heart_index],
            heart_y[heart_index]
        );
    }
    else if (ui_heart_bursting[heart_index])
    {
        draw_sprite(
            spr_heart_burst_1,
            floor(ui_heart_burst_frame[heart_index]),
            heart_x[heart_index],
            heart_y[heart_index]
        );
    }
}
