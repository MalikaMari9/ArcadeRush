var tile_width = sprite_get_width(spr_moving_tiles);
var tile_height = sprite_get_height(spr_moving_tiles);

// Keep the artwork centered at its native width. The margin layer draws
// above this layer and hides any small overlap at the sides.
var draw_x = (room_width - tile_width) * 0.5;

var run_controller = instance_find(obj_controller, 0);
var scroll_distance = (run_controller != noone)
    ? run_controller.distance_travelled
    : 0;
var scroll_offset = scroll_distance mod tile_height;

// Begin one full tile above the room, then repeat until the bottom is filled.
var draw_y = scroll_offset - tile_height;

while (draw_y < room_height)
{
    draw_sprite(spr_moving_tiles, 0, draw_x, draw_y);
    draw_y += tile_height;
}