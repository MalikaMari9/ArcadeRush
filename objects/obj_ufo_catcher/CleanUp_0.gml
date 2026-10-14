// If this catcher disappears unexpectedly, let the player recover on their
// next Step instead of leaving them permanently owned by a missing instance.
if (
    instance_exists(ufo_caught_player)
    && ufo_caught_player.ufo_captor == id
)
{
    ufo_caught_player.ufo_captor = noone;
}