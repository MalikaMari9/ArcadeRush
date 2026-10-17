// This room instance measures the first lane. Its scaled sprite is 208 px
// wide and centered at X 228, giving measured edges X 124 and X 332.
debug_lanes_visible = true;
debug_lane_count = 4;
debug_lane_left = x
    - sprite_get_xoffset(sprite_index) * abs(image_xscale);
debug_lane_width = sprite_get_width(sprite_index) * abs(image_xscale);
debug_lane_right = debug_lane_left
    + debug_lane_width * debug_lane_count;
