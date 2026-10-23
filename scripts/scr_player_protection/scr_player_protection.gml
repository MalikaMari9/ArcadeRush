enum PlayerDamageCause
{
    UNKNOWN,
    UFO,
    SCALPER,
    KEYMASTER,
    COIN,
    DUCK_SHOT,
    DUCK_EXPLOSION
}

function player_game_over_sprite(_cause)
{
    switch (_cause)
    {
        case PlayerDamageCause.UFO:
            return spr_gameover_ufo;
        case PlayerDamageCause.SCALPER:
            return spr_gameover_scalper;
        case PlayerDamageCause.KEYMASTER:
            return spr_gameover_keymaster;
        case PlayerDamageCause.COIN:
            return spr_gameover_coin;
        case PlayerDamageCause.DUCK_SHOT:
            return spr_gameover_duck_shoot;
        case PlayerDamageCause.DUCK_EXPLOSION:
            return spr_gameover_duck_explosion;
    }

    return spr_gameover_coin;
}

function player_get_protection_sprite(_lives)
{
    if (_lives <= 0) return spr_cat_hurt_expression;

    switch (_lives)
    {
        case 3: return spr_cat_back_bag;
        case 2: return spr_cat_back_tag;
        default: return spr_cat_back_body;
    }
}

// Call in the player instance's scope, directly or through with (player).
function player_refresh_appearance(_reset_frame = false)
{
    var retained_frame = _reset_frame ? 0 : image_index;
    var desired_sprite = player_get_protection_sprite(player_lives);

    if (sprite_index != desired_sprite)
    {
        sprite_index = desired_sprite;
        image_index = retained_frame;
    }
    else if (_reset_frame)
    {
        image_index = 0;
    }

    image_speed = 1;
    image_xscale = (player_lives <= 0) ? 1 : player_horizontal_facing;
}

// Call in the player instance's scope. Returns false when protection blocks it.
function player_apply_hazard_damage(_cause = PlayerDamageCause.UNKNOWN)
{
    if (invulnerable)
    {
        return false;
    }

    // The shield consumes one genuine hit before lives or other power-ups are
    // touched. Starting protection here also covers callers that only begin
    // i-frames after this function reports real life damage.
    if (powerup_shield_timer > 0)
    {
        powerup_shield_timer = 0;
        player_start_hazard_invulnerability();
        return false;
    }

    player_lives = max(0, player_lives - 1);
    player_last_damage_cause = _cause;

    // Any real life loss cancels the active Ticket Magnet. Contact during
    // invulnerability returns above, so protected hits do not remove it.
    ticket_magnet_timer = 0;
    ticket_double_timer = 0;

    if (player_lives <= 0)
    {
        player_dead = true;
        invulnerable = true;
        phase_through_obstacles = true;
        image_alpha = 1;
    }

    player_refresh_appearance(true);
    return true;
}

// Call in the player instance's scope.
function player_start_hazard_invulnerability()
{
    invulnerable = true;
    phase_through_obstacles = true;
    invulnerability_timer = invulnerability_duration;
    invulnerability_blink_timer = 0;
    image_alpha = 1;
}
