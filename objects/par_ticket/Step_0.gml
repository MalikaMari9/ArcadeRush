if (!instance_exists(ticket_controller))
{
    ticket_controller = instance_find(obj_controller, 0);
}

if (ticket_controller != noone)
{
    y += max(0, ticket_controller.world_scroll_delta);
}

// A collected Magnet pulls every individual ticket inside the player's
// radius. Collection and scoring still use the normal code below.
var magnet_player = instance_find(obj_player, 0);

if (
    magnet_player != noone
    && magnet_player.ticket_magnet_timer > 0
    && !magnet_player.ufo_captured
    && !magnet_player.scalper_captured
)
{
    var magnet_distance = point_distance(
        x,
        y,
        magnet_player.x,
        magnet_player.y
    );

    if (magnet_distance > 0 && magnet_distance <= magnet_player.ticket_magnet_radius)
    {
        var magnet_ratio = magnet_distance / magnet_player.ticket_magnet_radius;
        var magnet_speed = lerp(1000, 450, magnet_ratio);
        var magnet_step = min(
            magnet_distance,
            magnet_speed * game_delta_seconds()
        );
        var magnet_direction = point_direction(
            x,
            y,
            magnet_player.x,
            magnet_player.y
        );

        x += lengthdir_x(magnet_step, magnet_direction);
        y += lengthdir_y(magnet_step, magnet_direction);
    }
}

var ticket_width = sprite_get_width(sprite_index) * abs(image_xscale);
var ticket_height = sprite_get_height(sprite_index) * abs(image_yscale);
var ticket_origin_x = sprite_get_xoffset(sprite_index) * abs(image_xscale);
var ticket_origin_y = sprite_get_yoffset(sprite_index) * abs(image_yscale);
var ticket_top = y - ticket_origin_y;
var ticket_bottom = ticket_top + ticket_height;
var ticket_left = x - ticket_origin_x;
var ticket_right = ticket_left + ticket_width;

// Tickets win depth ties with blockers so an overlapping obstacle cannot
// render over the collectible. Keep this tied to the ticket's lower edge so
// player/world depth sorting still behaves naturally as the world scrolls.
depth = -floor(ticket_bottom) - 2;

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
        && !ticket_player.player_dead
        && !ticket_player.ufo_captured
        && !ticket_player.scalper_captured
    )
    {
        ticket_collected = true;

        if (ticket_controller != noone)
        {
            var ticket_multiplier = (ticket_player.ticket_double_timer > 0)
                ? 2
                : 1;
            ticket_controller.run_tickets += ticket_value * ticket_multiplier;
        }

        instance_destroy();
        exit;
    }
}

if (ticket_top > room_height + ticket_height)
{
    instance_destroy();
}
