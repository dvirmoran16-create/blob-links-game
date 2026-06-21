# Is Autoload!
extends Node

enum SecondaryAbility {
	NOTHING,
	PUSH_AWAY,
	PULL_IN,
	FREEZE_LINE,
	CONTINUOUS_PUSH_AWAY,
	CONTINUOUS_PULL_IN
}

# ── Current config ─────────────────────────────────────────────────────────
var is_ammo_auto_regen = true
var is_bullet_become_ammo_after_hit = false
var is_simple_enemy_become_blob_on_blue_dmg = true
var is_gain_speed_on_blink = true
var is_god_mode = false

var player_base_speed = 250
var starting_max_lives = 3
var starting_mana_threshold = 7

# cast
var cast_circle_duration = 3.0

# ammo
var starting_max_ammo = 5
var ammo_recharge_cooldown = 2.0
var ammo_recharge_pause = 1.0

var starting_blink_points_threshold = 7

func set_normal_values():
	player_base_speed = 250
	starting_max_lives = 3
	starting_max_ammo = 5
	ammo_recharge_cooldown = 2.0
	ammo_recharge_pause = 1.0
	
func set_god_values():
	player_base_speed = 625
	starting_max_lives = 100
	starting_max_ammo = 12
	ammo_recharge_cooldown = 0.5
	
