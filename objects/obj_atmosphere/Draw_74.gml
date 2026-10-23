atmosphere_capture_active = false;

if (!atmosphere_enabled || atmosphere_strength <= 0)
{
    exit;
}

var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

if (
    surface_exists(atmosphere_surface)
    && (
        surface_get_width(atmosphere_surface) != gui_width
        || surface_get_height(atmosphere_surface) != gui_height
    )
)
{
    surface_free(atmosphere_surface);
    atmosphere_surface = -1;
}

if (!surface_exists(atmosphere_surface))
{
    atmosphere_surface = surface_create(gui_width, gui_height);
}

if (!surface_exists(atmosphere_surface))
{
    exit;
}

surface_set_target(atmosphere_surface);
draw_clear_alpha(c_black, 0);
draw_surface_stretched(
    application_surface,
    0,
    0,
    gui_width,
    gui_height
);
atmosphere_capture_active = true;
