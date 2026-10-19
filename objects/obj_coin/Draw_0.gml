switch (coin_state)
{
    case 1:
        draw_sprite_ext(
            spr_coins, 0, x + coin_shake_x, y + coin_shake_y,
            coin_scale, coin_scale, 0, c_white, image_alpha
        );
        break;

    case 2:
        draw_sprite_ext(
            spr_coin_fall, 0,
            x + coin_shake_x, y + coin_shake_y,
            coin_fall_direction * coin_scale, coin_scale,
            0, c_white, image_alpha
        );
        break;

    case 3:
        draw_sprite_ext(
            spr_coin_flat, 0,
            x + coin_shake_x, y + coin_shake_y,
            coin_scale, coin_scale, 0, c_white, image_alpha
        );
        break;

    default:
        draw_self();
        break;
}
