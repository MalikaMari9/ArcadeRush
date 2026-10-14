// Recover if a catcher disappears before completing its release sequence.
if (ufo_captured && !instance_exists(ufo_captor))
{
    var recovery_controller = instance_find(obj_controller, 0);
    var recovery_left = (recovery_controller != noone)
        ? recovery_controller.blocker_spawn_left
        : 128;
    var recovery_right = (recovery_controller != noone)
        ? recovery_controller.blocker_spawn_right
        : 960;
    var recovery_left_offset = bbox_left - x;
    var recovery_right_offset = bbox_right - x;
    var recovery_top_offset = bbox_top - y;
    var recovery_bottom_offset = bbox_bottom - y;
    var recovery_min_x = recovery_left + 8 - recovery_left_offset;
    var recovery_max_x = recovery_right - 8 - recovery_right_offset;
    var recovery_min_y = -recovery_top_offset;
    var recovery_max_y = (room_height - 1) - recovery_bottom_offset;

    x = clamp(x, recovery_min_x, recovery_max_x);
    y = clamp(y, recovery_min_y, recovery_max_y);

    var recovery_found = !place_meeting(x, y, par_blocker);
    var recovery_step = 8;

    for (
        var recovery_y = recovery_min_y;
        recovery_y <= recovery_max_y && !recovery_found;
        recovery_y += recovery_step
    )
    {
        for (
            var recovery_x = recovery_min_x;
            recovery_x <= recovery_max_x && !recovery_found;
            recovery_x += recovery_step
        )
        {
            if (!place_meeting(recovery_x, recovery_y, par_blocker))
            {
                x = recovery_x;
                y = recovery_y;
                recovery_found = true;
            }
        }
    }

    ufo_captured = false;
    ufo_captor = noone;
    player_start_hazard_invulnerability();
}
// Blink while protected, then always restore full opacity.
if (invulnerable)
{
    var protection_delta = game_delta_seconds();
    invulnerability_timer = max(0, invulnerability_timer - protection_delta);
    invulnerability_blink_timer -= protection_delta;

    if (invulnerability_timer <= 0)
    {
        invulnerable = false;
        image_alpha = 1;
    }
    else if (invulnerability_blink_timer <= 0)
    {
        invulnerability_blink_timer += invulnerability_blink_interval;
        image_alpha = (image_alpha > 0.5) ? 0.35 : 1;
    }
}
else
{
    image_alpha = 1;
}

// The catcher owns the player's position until it releases them.
if (ufo_captured)
{
    image_speed = 0;
    image_index = 0;
    exit;
}

// Read WASD input as a two-dimensional player movement vector.
var input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

// Temporary test controls: 3 = bag, 2 = tag, 1 = body.
if (keyboard_check_pressed(ord("3"))) player_lives = 3;
if (keyboard_check_pressed(ord("2"))) player_lives = 2;
if (keyboard_check_pressed(ord("1"))) player_lives = 1;

// Vertical input selects front/back. Pure horizontal movement keeps the
// last vertical facing, while horizontal input mirrors the artwork.
if (input_y > 0)
{
    player_vertical_facing = 1;
}
else if (input_y < 0)
{
    player_vertical_facing = -1;
}

if (input_x != 0)
{
    player_horizontal_facing = sign(input_x);
}

player_refresh_appearance();

// The world is always moving, so the player keeps walking without input.
// A multiplier of 1 uses the sprite's configured 5 FPS speed.
image_speed = 1;

// Normalize input so diagonal movement is not faster.
var input_length = sqrt(input_x * input_x + input_y * input_y);

if (input_length > 0)
{
    input_x /= input_length;
    input_y /= input_length;
}

var delta_seconds = delta_time / 1000000;

var move_x = input_x * move_speed * delta_seconds;
var move_y = input_y * move_speed * delta_seconds;

// Resolve horizontal movement first. Sub-pixel steps prevent tunneling.
if (move_x != 0)
{
    var horizontal_steps = ceil(abs(move_x));
    var horizontal_step = move_x / horizontal_steps;

    repeat (horizontal_steps)
    {
        if (!place_meeting(x + horizontal_step, y, par_blocker))
        {
            x += horizontal_step;
        }
        else
        {
            break;
        }
    }
}

// Resolve vertical movement separately so the player slides along walls.
if (move_y != 0)
{
    var vertical_steps = ceil(abs(move_y));
    var vertical_step = move_y / vertical_steps;

    repeat (vertical_steps)
    {
        if (!place_meeting(x, y + vertical_step, par_blocker))
        {
            y += vertical_step;
        }
        else
        {
            break;
        }
    }
}

// Keep the player's complete collision mask inside the room.
var mask_left_offset = bbox_left - x;
var mask_right_offset = bbox_right - x;
var mask_top_offset = bbox_top - y;
var mask_bottom_offset = bbox_bottom - y;

x = clamp(
    x,
    -mask_left_offset,
    (room_width - 1) - mask_right_offset
);

y = clamp(
    y,
    -mask_top_offset,
    (room_height - 1) - mask_bottom_offset
);
