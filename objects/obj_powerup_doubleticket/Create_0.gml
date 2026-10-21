event_inherited();

powerup_apply = function(_player)
{
    // Refresh to the full duration; duplicate boosters never become x4.
    _player.ticket_double_timer = _player.ticket_double_duration;
};
