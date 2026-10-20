var source_height = sprite_get_height(sprite_index);
var draw_top = y - sprite_get_yoffset(sprite_index);
var middle_draw_width = max(
    ufo_middle_source_width,
    ufo_draw_width - ufo_head_width - ufo_tail_width
);
var middle_scale = middle_draw_width / ufo_middle_source_width;

if (ufo_side == 1)
{
    // Right-side attack: the head is the far-left piece.
    var draw_left = x - ufo_draw_width;
    draw_sprite_part_ext(
        sprite_index, image_index,
        0, 0, ufo_head_width, source_height,
        draw_left, draw_top,
        1, 1, c_white, 1
    );
    draw_sprite_part_ext(
        sprite_index, image_index,
        ufo_head_width, 0, ufo_middle_source_width, source_height,
        draw_left + ufo_head_width, draw_top,
        middle_scale, 1, c_white, 1
    );
    draw_sprite_part_ext(
        sprite_index, image_index,
        ufo_head_width + ufo_middle_source_width, 0,
        ufo_tail_width, source_height,
        x - ufo_tail_width, draw_top,
        1, 1, c_white, 1
    );
}
else
{
    // Left-side attack: mirror each piece and reverse their placement.
    draw_sprite_part_ext(
        sprite_index, image_index,
        ufo_head_width + ufo_middle_source_width, 0,
        ufo_tail_width, source_height,
        x + ufo_tail_width, draw_top,
        -1, 1, c_white, 1
    );
    draw_sprite_part_ext(
        sprite_index, image_index,
        ufo_head_width, 0, ufo_middle_source_width, source_height,
        x + ufo_tail_width + middle_draw_width, draw_top,
        -middle_scale, 1, c_white, 1
    );
    draw_sprite_part_ext(
        sprite_index, image_index,
        0, 0, ufo_head_width, source_height,
        x + ufo_draw_width, draw_top,
        -1, 1, c_white, 1
    );
}
