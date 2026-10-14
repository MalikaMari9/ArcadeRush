function game_delta_seconds()
{
    return min(delta_time / 1000000, 1 / 15);
}