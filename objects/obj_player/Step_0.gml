// First room beat: rise from below with a restrained overshoot, then settle
// at the exact position authored in the Room Editor.
if (player_entering)
{
    player_entry_progress = min(
        1,
        player_entry_progress
            + min(delta_time / 1000000, 1 / 15) / player_entry_duration
    );

    var entry_offset = player_entry_progress - 1;
    var entry_overshoot = 0.7;
    var entry_eased = 1
        + (entry_overshoot + 1) * power(entry_offset, 3)
        + entry_overshoot * power(entry_offset, 2);

    x = player_rest_x;
    y = lerp(player_entry_start_y, player_rest_y, entry_eased);
    player_refresh_appearance();
    image_speed = 1;

    if (player_entry_progress >= 1)
    {
        y = player_rest_y;
        player_entering = false;
    }

    exit;
}

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

// Fail safe: never leave movement locked if the permanent crowd disappears.
if (scalper_captured && !instance_exists(obj_scalpers))
{
    scalper_captured = false;
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

// Power-up time continues normally even while a hazard controls the player.
ticket_magnet_timer = max(
    0,
    ticket_magnet_timer - game_delta_seconds()
);

if (ticket_magnet_timer > 0)
{
    ticket_magnet_visual_frame = (
        ticket_magnet_visual_frame + 5 * game_delta_seconds()
    ) mod sprite_get_number(spr_magnet_anim);
    ticket_magnet_visual_time += game_delta_seconds();
}
else
{
    ticket_magnet_visual_frame = 0;
    ticket_magnet_visual_time = 0;
}

ticket_double_timer = max(
    0,
    ticket_double_timer - game_delta_seconds()
);

if (ticket_double_timer > 0)
{
    ticket_double_visual_frame = (
        ticket_double_visual_frame + 5 * game_delta_seconds()
    ) mod sprite_get_number(spr_double_ticket);
    ticket_double_visual_time += game_delta_seconds();
}
else
{
    ticket_double_visual_frame = 0;
    ticket_double_visual_time = 0;
}

powerup_shield_timer = max(
    0,
    powerup_shield_timer - game_delta_seconds()
);

if (powerup_shield_timer > 0)
{
    powerup_shield_visual_time += game_delta_seconds();
}
else
{
    powerup_shield_visual_time = 0;
}

// If protection ends while overlapping a moving obstacle, remain intangible
// until completely clear so collision cannot reactivate around the player.
if (
    phase_through_obstacles
    && !invulnerable
    && !place_meeting(x, y, par_scrolling_blocker)
)
{
    phase_through_obstacles = false;
}

// The catcher owns the player's position until it releases them.
if (ufo_captured)
{
    image_speed = 0;
    image_index = 0;
    exit;
}

// The Scalpers briefly own the player's position during their bite. Keep the
// walking animation alive so the world still feels in motion.
if (scalper_captured)
{
    image_speed = 1;
    exit;
}

// A lethal hit leaves the runner facing the camera in the hurt animation.
// The controller waits for this pose before freezing the scene and opening
// the game-over presentation.
if (player_dead)
{
    player_refresh_appearance();
    image_alpha = 1;
    image_xscale = 1;
    image_speed = 1;
    exit;
}

// Stay animated but ignore movement until the room countdown reaches GO.
var run_controller = instance_find(obj_controller, 0);
if (run_controller != noone && !run_controller.run_started)
{
    player_refresh_appearance();
    image_speed = 1;
    exit;
}

// Read WASD input as a two-dimensional player movement vector.
var input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

// Mobile and mouse testing use the same movement path as the keyboard so
// collision resolution, margins, and obstacle sliding remain authoritative.
var touch_controller = instance_find(obj_touch_controller, 0);
if (touch_controller != noone)
{
    input_x += touch_controller.touch_move_x;
    input_y += touch_controller.touch_move_y;
}

// Temporary test controls: 3 = bag, 2 = tag, 1 = body.
if (keyboard_check_pressed(ord("3"))) player_lives = 3;
if (keyboard_check_pressed(ord("2"))) player_lives = 2;
if (keyboard_check_pressed(ord("1"))) player_lives = 1;

// Horizontal input mirrors the back-facing artwork.
if (input_x != 0)
{
    player_horizontal_facing = sign(input_x);
}

player_refresh_appearance();

// The world is always moving, so the player keeps walking without input.
// A multiplier of 1 uses the sprite's configured 5 FPS speed.
image_speed = 1;

// Cap combined keyboard/touch input so diagonals are not faster while
// retaining the joystick's analogue strength inside its outer radius.
var input_length = sqrt(input_x * input_x + input_y * input_y);

if (input_length > 1)
{
    input_x /= input_length;
    input_y /= input_length;
}

var delta_seconds = delta_time / 1000000;

var move_x = input_x * move_speed * delta_seconds;
var move_y = input_y * move_speed * delta_seconds;
var movement_blocker = phase_through_obstacles ? obj_margin : par_blocker;

// Resolve horizontal movement first. Sub-pixel steps prevent tunneling.
if (move_x != 0)
{
    var horizontal_steps = ceil(abs(move_x));
    var horizontal_step = move_x / horizontal_steps;

    repeat (horizontal_steps)
    {
        if (!place_meeting(x + horizontal_step, y, movement_blocker))
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
        if (!place_meeting(x, y + vertical_step, movement_blocker))
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
