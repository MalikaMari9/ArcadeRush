function game_delta_seconds(_ignore_game_over = false)
{
    if (!_ignore_game_over)
    {
        if (instance_exists(obj_gameover)) return 0;
    }

    return min(delta_time / 1000000, 1 / 15);
}
