event_inherited();

powerup_apply = function(_player)
{
    // Refresh to the full duration; duplicate power-ups never stack.
    _player.ticket_magnet_timer = _player.ticket_magnet_duration;
};
