function player_get_protection_sprite(_lives, _vertical_facing)
{
    if (_vertical_facing == 1)
    {
        switch (_lives)
        {
            case 3: return spr_cat_front_bag;
            case 2: return spr_cat_front_tag;
            default: return spr_cat_front_body;
        }
    }

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
    var desired_sprite = player_get_protection_sprite(
        player_lives,
        player_vertical_facing
    );

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
    image_xscale = player_horizontal_facing;
}

// Call in the player instance's scope. Returns false when protection blocks it.
function player_apply_hazard_damage()
{
    if (invulnerable)
    {
        return false;
    }

    player_lives -= 1;

    // Temporary game-over stand-in until the final game-over flow exists.
    if (player_lives <= 0)
    {
        player_lives = 3;
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
