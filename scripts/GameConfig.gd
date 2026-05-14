# GameConfig.gd  — add to Project > Autoloads
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
var is_ammo_auto_regen = false
var is_bullet_become_ammo_after_hit = false
var is_simple_enemy_become_blob_on_blue_dmg = true
