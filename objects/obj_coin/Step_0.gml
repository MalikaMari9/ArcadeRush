var delta_seconds = game_delta_seconds();
var run_controller = instance_find(obj_controller, 0);
coin_shake_clock += delta_seconds;

if (coin_state == 0 || coin_state == 1 || coin_state == 3)
{
    // Parent supplies scrolling, player pushing, depth, and offscreen cleanup.
    event_inherited();

    if (coin_state == 0 && y >= coin_warning_y)
    {
        // Only commit when the adjacent landing lane is unobstructed.
        var landing_half_width = sprite_get_width(spr_coin_flat)
            * coin_scale * 0.5;
        var landing_clear = collision_rectangle(
            coin_target_x - landing_half_width,
            y - sprite_get_height(spr_coins) * coin_scale,
            coin_target_x + landing_half_width,
            y,
            par_scrolling_blocker,
            false,
            true
        ) == noone;

        if (
            !landing_clear
            && coin_start_lane > 0
            && coin_start_lane < coin_lane_count - 1
        )
        {
            var alternate_x = x - coin_fall_direction * coin_lane_width;
            landing_clear = collision_rectangle(
                alternate_x - landing_half_width,
                y - sprite_get_height(spr_coins) * coin_scale,
                alternate_x + landing_half_width,
                y,
                par_scrolling_blocker,
                false,
                true
            ) == noone;

            if (landing_clear)
            {
                coin_fall_direction *= -1;
                coin_target_x = alternate_x;
            }
        }

        if (landing_clear)
        {
            coin_state = 1;
        }
    }
    else if (coin_state == 1)
    {
        coin_warning_timer = max(0, coin_warning_timer - delta_seconds);
        var warning_progress = 1 - coin_warning_timer / coin_warning_duration;
        coin_shake_x = sin(coin_shake_clock * 58) * 3.5
            * warning_progress;
        coin_shake_y = sin(coin_shake_clock * 83) * 1.5
            * warning_progress;

        if (coin_warning_timer <= 0)
        {
            coin_state = 2;
            coin_fall_progress = 0;
            coin_shake_x = 0;
            coin_shake_y = 0;
            coin_start_x = x;
            coin_target_x = x + coin_fall_direction
                * coin_lane_width;

            // No solid blocker mask during the timed fall.
            sprite_index = -1;
            mask_index = -1;
        }
    }

    if (coin_state == 3)
    {
        coin_flat_shake_timer = max(
            0,
            coin_flat_shake_timer - delta_seconds
        );
        var flat_progress = 1
            - coin_flat_shake_timer / coin_flat_shake_duration;
        var flat_shake_strength = 1 - flat_progress;
        coin_shake_x = sin(flat_progress * pi * 6)
            * 3 * flat_shake_strength;
        coin_shake_y = sin(flat_progress * pi * 12)
            * 1.25 * flat_shake_strength;
    }

    exit;
}

// The tower follows the scrolling world while its fall is shown in place.
if (run_controller != noone)
{
    y += max(0, run_controller.world_scroll_delta);
}

coin_fall_progress = min(
    1,
    coin_fall_progress + delta_seconds / coin_fall_duration
);
// Keep the falling artwork anchored to the upright tower's origin.
x = coin_start_x;
coin_shake_x = sin(coin_shake_clock * 65) * 3.5;
coin_shake_y = sin(coin_shake_clock * 89) * 1.5;
depth = -y - 1;

// The warning and falling artwork are safe; only landing can crush the player.
if (coin_fall_progress >= 1)
{
    var half_width = sprite_get_width(spr_coin_flat) * coin_scale * 0.5;
    var hit_player = collision_rectangle(
        coin_target_x - half_width,
        y - sprite_get_height(spr_coin_flat) * coin_scale,
        coin_target_x + half_width,
        y,
        obj_player, false, true
    );

    if (
        hit_player != noone
        && !hit_player.ufo_captured
        && !hit_player.scalper_captured
        && !hit_player.invulnerable
    )
    {
        with (hit_player)
        {
            if (player_apply_hazard_damage(PlayerDamageCause.COIN))
            {
                player_start_hazard_invulnerability();
            }
        }
    }

    x = coin_target_x;
    sprite_index = spr_coin_flat;
    mask_index = -1;
    coin_flat_shake_timer = coin_flat_shake_duration;
    coin_shake_x = 0;
    coin_shake_y = 0;
    coin_state = 3;
}
