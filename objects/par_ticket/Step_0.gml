if (!instance_exists(ticket_controller))
{
    ticket_controller = instance_find(obj_controller, 0);
}

if (ticket_controller != noone)
{
    y += max(0, ticket_controller.world_scroll_delta);
}

var ticket_width = sprite_get_width(sprite_index) * abs(image_xscale);
var ticket_height = sprite_get_height(sprite_index) * abs(image_yscale);
var ticket_origin_x = sprite_get_xoffset(sprite_index) * abs(image_xscale);
var ticket_origin_y = sprite_get_yoffset(sprite_index) * abs(image_yscale);
var ticket_top = y - ticket_origin_y;
var ticket_bottom = ticket_top + ticket_height;
var ticket_left = x - ticket_origin_x;
var ticket_right = ticket_left + ticket_width;

depth = -floor(ticket_bottom);

if (!ticket_collected)
{
    var ticket_player = collision_rectangle(
        ticket_left,
        ticket_top,
        ticket_right,
        ticket_bottom,
        obj_player,
        false,
        true
    );

    if (
        ticket_player != noone
        && !ticket_player.ufo_captured
        && !ticket_player.scalper_captured
    )
    {
        ticket_collected = true;

        if (ticket_controller != noone)
        {
            ticket_controller.run_tickets += ticket_value;
        }

        instance_destroy();
        exit;
    }
}

if (ticket_top > room_height + ticket_height)
{
    instance_destroy();
}
