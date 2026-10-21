if (!instance_exists(powerup_controller))
{
    powerup_controller = instance_find(obj_controller, 0);
}

if (powerup_controller != noone)
{
    y += max(0, powerup_controller.world_scroll_delta);
}

var powerup_player = instance_place(x, y, obj_player);

if (
    powerup_player != noone
    && !powerup_player.ufo_captured
    && !powerup_player.scalper_captured
)
{
    powerup_apply(powerup_player);
    instance_destroy();
    exit;
}

if (bbox_top > room_height + sprite_height)
{
    instance_destroy();
}
