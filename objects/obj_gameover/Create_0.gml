game_over_time = 0;
game_over_cause = PlayerDamageCause.UNKNOWN;
game_over_box_duration = 0.35;
game_over_illustration_delay = 0.18;
game_over_illustration_duration = 0.65;
game_over_retry_delay = 1.05;
game_over_retry_duration = 0.25;

var defeated_player = instance_find(obj_player, 0);
if (defeated_player != noone)
    game_over_cause = defeated_player.player_last_damage_cause;
