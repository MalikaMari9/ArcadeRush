if (surface_exists(atmosphere_surface))
{
    surface_free(atmosphere_surface);
    atmosphere_surface = -1;
}
