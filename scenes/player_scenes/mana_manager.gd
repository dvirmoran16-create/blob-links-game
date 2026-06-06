class_name ManaManager
extends Node2D

var max_mana = 7  # GameConfig.starting_max_magic
var current_mana = 0

@onready var mana_circle : TextureProgressBar = $ManaCircle

func _ready() -> void:
	mana_circle.value = 0
	
func _on_player_leaped() -> void:
	if current_mana < max_mana:
		current_mana += 1
		mana_circle.value = current_mana
		if current_mana == max_mana:
			mana_circle.tint_progress.a = 1.0
		
func _on_player_cast() -> void:
	current_mana = 0
	mana_circle.value = 0
	mana_circle.tint_progress.a = 0.7
