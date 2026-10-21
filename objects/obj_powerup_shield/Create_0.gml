event_inherited();

powerup_apply = function(_player)
{
    // A duplicate refreshes the shield window; it never adds another charge.
    _player.powerup_shield_timer = _player.powerup_shield_duration;
};
